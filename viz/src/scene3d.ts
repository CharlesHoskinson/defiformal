/* CSS3D layer.
 *
 * Built to the motion council's constraints, which exist to stop 3D breaking
 * a table that finally works:
 *   - the resting state is the packed table, face-on and pixel-crisp
 *   - near-orthographic camera (low FOV), shallow Z, no horizon/fog/gloss
 *   - orbit is clamped and springs home; tiles never leave the view plane
 *   - focus drives the camera, or keyboard focus silently vanishes behind planes
 *   - wrap-as-mode: the same DOM nodes are re-parented in and out, never cloned
 *   - reduced motion collapses every transition to an instant state change
 */
import {
  Object3D, PerspectiveCamera, Scene, Vector3,
} from "three";
import { CSS3DObject, CSS3DRenderer } from "three/examples/jsm/renderers/CSS3DRenderer.js";

export interface Box { x: number; y: number; w: number; h: number; z: number }

const FOV = 38;                 // real perspective: the depth has to be visible
const MAX_YAW = 0.46;           // ~26°, still readable, no longer timid
const MAX_PITCH = 0.30;
const REST_YAW = 0.21;          // resting angle, so depth reads without input
const REST_PITCH = 0.13;

const ease = (t: number) => 1 - Math.pow(1 - t, 3);

export class Scene3D {
  scene = new Scene();
  camera: PerspectiveCamera;
  renderer = new CSS3DRenderer();
  objects = new Map<string, CSS3DObject>();
  private home = new Vector3();
  private target = new Vector3();
  private yaw = REST_YAW; private pitch = REST_PITCH;
  private wantYaw = REST_YAW; private wantPitch = REST_PITCH;
  private raf = 0;
  private tweens: { o: CSS3DObject; from: Vector3; to: Vector3; t0: number; d: number; delay: number }[] = [];
  private spin: { o: CSS3DObject; c: Vector3; r: number; a: number; sp: number; laps: number; max: number }[] = [];
  private dragging = false;
  private reduce: boolean;
  private frameH = 0;
  onSpiralEnd: (() => void) | null = null;

  constructor(private host: HTMLElement, reduce: boolean) {
    this.reduce = reduce;
    this.camera = new PerspectiveCamera(FOV, 1, 1, 20000);
    this.renderer.domElement.style.position = "absolute";
    this.renderer.domElement.style.inset = "0";
    this.renderer.domElement.style.pointerEvents = "none";
    host.appendChild(this.renderer.domElement);
    this.bindDrag();
    this.loop();
  }

  /** Lift measured 2D boxes into the scene. Same nodes, re-parented. */
  mount(boxes: Map<string, { el: HTMLElement; box: Box }>, w: number, h: number, frameH?: number) {
    this.objects.forEach((o) => this.scene.remove(o));
    this.objects.clear();
    for (const [id, { el, box }] of boxes) {
      el.style.position = "absolute";
      el.style.left = "0"; el.style.top = "0";
      el.style.width = `${box.w}px`; el.style.height = `${box.h}px`;
      el.style.margin = "0";
      const o = new CSS3DObject(el);
      o.position.set(box.x, box.y, box.z);
      this.scene.add(o);
      this.objects.set(id, o);
    }
    this.resize(w, h, frameH);
  }

  /** Put every tile back where the document wants it. */
  unmount() {
    this.objects.forEach((o, id) => {
      const el = o.element as HTMLElement;
      el.style.position = ""; el.style.left = ""; el.style.top = "";
      el.style.width = ""; el.style.height = ""; el.style.margin = "";
      el.style.transform = "";
      this.scene.remove(o);
      void id;
    });
    this.objects.clear();
  }

  resize(w: number, h: number, frameH?: number) {
    this.camera.aspect = w / h;
    if (frameH) this.frameH = frameH;
    // frame the content extent at this FOV, not the flat document height
    const d = (this.frameH || h) / 2 / Math.tan((FOV * Math.PI) / 360);
    this.home.set(0, 0, d);
    this.target.copy(this.home);
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(w, h);
  }

  /** Move tiles to new positions. Members can be pulled toward the viewer. */
  moveTo(next: Map<string, Vector3>, stagger = 34, dur = 520) {
    const now = performance.now();
    this.tweens = [];
    let i = 0;
    for (const [id, to] of next) {
      const o = this.objects.get(id);
      if (!o) continue;
      if (this.reduce) { o.position.copy(to); continue; }
      if (o.position.distanceToSquared(to) < 0.25) continue;
      this.tweens.push({ o, from: o.position.clone(), to: to.clone(), t0: now, d: dur, delay: i * stagger });
      i++;
    }
  }

  /** The death spiral: accelerating, tightening, then it breaks. */
  spiral(ids: string[], laps = 3) {
    if (this.reduce) { this.onSpiralEnd?.(); return; }
    const centre = new Vector3();
    ids.forEach((id) => { const o = this.objects.get(id); if (o) centre.add(o.position); });
    centre.divideScalar(Math.max(1, ids.length));
    centre.z += 220;
    this.spin = ids.map((id, k) => {
      const o = this.objects.get(id)!;
      return {
        o, c: centre.clone(),
        r: o.position.distanceTo(centre) || 180,
        a: (k / ids.length) * Math.PI * 2,
        sp: 0.018, laps: 0, max: laps,
      };
    }).filter((s) => s.o);
  }

  stopSpiral() { this.spin = []; }

  /** Camera follows focus, or a focused tile can sit behind a plane unseen. */
  focusOn(id: string) {
    const o = this.objects.get(id);
    if (!o) return;
    this.wantYaw = REST_YAW * 0.45; this.wantPitch = REST_PITCH * 0.45;
    this.target.set(o.position.x * 0.25, o.position.y * 0.25, this.home.z - o.position.z * 0.5);
  }

  home_() { this.target.copy(this.home); this.wantYaw = REST_YAW; this.wantPitch = REST_PITCH; }

  private bindDrag() {
    const d = this.host;
    let sx = 0, sy = 0, y0 = 0, p0 = 0;
    d.addEventListener("pointerdown", (e) => {
      if ((e.target as HTMLElement).closest(".tile")) return;
      this.dragging = true; sx = e.clientX; sy = e.clientY; y0 = this.wantYaw; p0 = this.wantPitch;
      d.setPointerCapture(e.pointerId);
    });
    d.addEventListener("pointermove", (e) => {
      if (!this.dragging) return;
      this.wantYaw = Math.max(-MAX_YAW, Math.min(MAX_YAW, y0 + (e.clientX - sx) * 0.0012));
      this.wantPitch = Math.max(-MAX_PITCH, Math.min(MAX_PITCH, p0 - (e.clientY - sy) * 0.0012));
    });
    const end = () => { this.dragging = false; this.wantYaw = REST_YAW; this.wantPitch = REST_PITCH; };
    d.addEventListener("pointerup", end);
    d.addEventListener("pointercancel", end);
  }

  private loop = () => {
    this.raf = requestAnimationFrame(this.loop);
    const now = performance.now();

    if (this.tweens.length) {
      this.tweens = this.tweens.filter((tw) => {
        const t = (now - tw.t0 - tw.delay) / tw.d;
        if (t <= 0) return true;
        const k = ease(Math.min(1, t));
        tw.o.position.lerpVectors(tw.from, tw.to, k);
        return t < 1;
      });
    }

    if (this.spin.length) {
      let done = false;
      for (const s of this.spin) {
        s.a += s.sp;
        s.sp *= 1.012;              // accelerate
        s.r *= 0.9975;              // tighten
        if (s.a > Math.PI * 2 * (s.laps + 1)) s.laps++;
        if (s.laps >= s.max) done = true;
        s.o.position.set(
          s.c.x + Math.cos(s.a) * s.r,
          s.c.y + Math.sin(s.a) * s.r * 0.55,
          s.c.z + Math.sin(s.a * 0.5) * 40
        );
      }
      if (done) { this.spin = []; this.onSpiralEnd?.(); }
    }

    // spring the camera home; never drifts on its own
    this.yaw += (this.wantYaw - this.yaw) * 0.09;
    this.pitch += (this.wantPitch - this.pitch) * 0.09;
    const d = this.target.z;
    this.camera.position.set(
      this.target.x + Math.sin(this.yaw) * d,
      this.target.y + Math.sin(this.pitch) * d,
      Math.cos(this.yaw) * Math.cos(this.pitch) * d
    );
    this.camera.lookAt(this.target.x, this.target.y, 0);
    this.renderer.render(this.scene, this.camera);
  };

  dispose() {
    cancelAnimationFrame(this.raf);
    this.unmount();
    this.scene.traverse((o: Object3D) => void o);
    this.renderer.domElement.remove();
  }

}
