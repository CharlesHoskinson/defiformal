const fs=require('node:fs');
const ts=require('/home/charl/.npm-global/lib/node_modules/typescript/lib/typescript.js');
const input=JSON.parse(fs.readFileSync(0,'utf8'));
const ast=ts.createSourceFile(input.path,input.text,ts.ScriptTarget.Latest,true,ts.ScriptKind.TS);
const edges=[], unresolved=[];
const literal=n=>n&&(ts.isStringLiteral(n)||ts.isNoSubstitutionTemplateLiteral(n));
function add(kind,n,node){const line=ast.getLineAndCharacterOfPosition(node.getStart()).line+1;if(literal(n))edges.push({kind,specifier:n.text,line});else unresolved.push({kind,line,text:node.getText(ast)});}
function visit(n){
 if(ts.isImportDeclaration(n)||ts.isExportDeclaration(n)){if(n.moduleSpecifier)add('module',n.moduleSpecifier,n);}
 if(ts.isCallExpression(n)&& (n.expression.kind===ts.SyntaxKind.ImportKeyword || (ts.isIdentifier(n.expression)&&n.expression.text==='require')))add('dynamic-module',n.arguments[0],n);
 if(ts.isNewExpression(n)&&ts.isIdentifier(n.expression)&&n.expression.text==='URL')add('url-resource',n.arguments?.[0],n);
 ts.forEachChild(n,visit);
}
visit(ast);
console.log(JSON.stringify({typescript_version:ts.version,parse_diagnostics:ast.parseDiagnostics.map(d=>({start:d.start,message:ts.flattenDiagnosticMessageText(d.messageText,' ')})),edges,unresolved}));
