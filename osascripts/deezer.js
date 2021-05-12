let output = "";
let app = Application("Google Chrome");
if (app.running()){
  output=app.windows().flatMap(x=>x.tabs()).filter(x=>x.url().includes("deezer.com")).map(x=>x.title());
}
output;
