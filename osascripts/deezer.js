let output = "Why aren't you listening to music with deezer :) ?";
let app = Application("Google Chrome");
if (app.running()){
  let result=[...new Set(app.windows().flatMap(x=>x.tabs()).filter(x=>x.url().includes("deezer.com")).map(x=>x.title()))];
  if(result.length > 0) {
    output=result;
  }
}
output;
