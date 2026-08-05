import json

d = json.load(open("/tmp/common.ir.json"))
mods = d["modules"]
print("modules:", [m["name"] for m in mods])
m = mods[0]
print("module keys:", list(m.keys()))
decls = m.get("declarations", m.get("defs", []))
print("n decls:", len(decls))
kinds = {}
for de in decls:
    kinds[de.get("kind")] = kinds.get(de.get("kind"), 0) + 1
print("kinds:", kinds)

# show one operator decl fully
for de in decls:
    if de.get("kind") == "def":
        print("\n--- sample def ---")
        print(json.dumps({k: v for k, v in de.items() if k != "expr"}, indent=2)[:1500])
        break

# how are types represented?
print("\n--- typed decls (name -> type) ---")
n = 0
for de in decls:
    t = de.get("typeAnnotation")
    if t and de.get("name"):
        print(" ", de["name"], "::", json.dumps(t)[:180])
        n += 1
        if n >= 8:
            break
print("\ntable entries:", len(d.get("table", {})))
