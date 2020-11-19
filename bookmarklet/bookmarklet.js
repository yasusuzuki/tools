javascript:(()=>{
  var div = document.createElement("div"); 
  div.setAttribute("style","padding: 16px;border: 1px solid transparent;border-radius: 3px;border-color: #a0c7e4;background-color: #e1ecf4;margin: 0px 20px 0 20px;");
  div.innerText = window.getSelection().toString();
  window.getSelection().getRangeAt(0).deleteContents();
  window.getSelection().getRangeAt(0).insertNode(div);
})()

javascript:(()=>{
  var div = document.createElement("div"); 
  div.setAttribute("style","padding: 16px;border: 1px solid transparent;border-radius: 3px;border-color: #fffbdd;background-color: rgb(176 136 0 / 21%);;margin: 0px 20px 0 20px;");
  div.innerText = window.getSelection().toString();
  window.getSelection().getRangeAt(0).deleteContents();
  window.getSelection().getRangeAt(0).insertNode(div);
})()


javascript:(()=>{
  var div = document.createElement("div"); 
  div.setAttribute("style","padding: 16px;border: 1px solid transparent;border-radius: 3px;border-color: #EFE4B1;background-color: #FFFBDD;margin: 0px 20px 0 20px;");
  div.innerText = window.getSelection().toString();
  window.getSelection().getRangeAt(0).deleteContents();
  window.getSelection().getRangeAt(0).insertNode(div);
})()

javascript:(()=>{
  var div = document.createElement("h3");
  div.setAttribute("style","border-bottom: 1px solid #ddd; box-shadow: 0.1em 0.4em 0.7em 0 #f2f2f2; padding: 0.2em .3em .1em;");
  div.innerText = window.getSelection().toString();
  window.getSelection().getRangeAt(0).deleteContents();
  window.getSelection().getRangeAt(0).insertNode(div);
})()



//Format Clipbard from URL Encoced to URL Decoded
// Basic version. Clipbaord access is allowed only inside "paste" event listern, you need to press Ctrl+V to trigger this function.
javascript:(()=>{document.addEventListener("paste", function (e) {
  clip = e.clipboardData || window.clipboardData; copied = clip.getData('Text'); copied=decodeURIComponent(copied);
});})()
// Advanced version Clipboard API doesn't require Ctrl+v trigger,but it must run on the Web Page over "HTTPS" , and the page is "focused", due to some restriction on writeText() 
//https://web.dev/async-clipboard/
javascript:(()=>{
  navigator.clipboard.readText().then(clipText =>navigator.clipboard.writeText(decodeURIComponent(clipText )));
})()

// Advanced version 2. Insert docededURI to the textare where you focus on. Ex. Gmail ..
javascript:(()=>{
  navigator.clipboard.readText().then(clipText =>document.activeElement.innerHTML +=  decodeURIComponent(clipText));
})()


//Remove sidebar panel on Redmine
$('#sidebar').css({'width':'0%','display':'none'});$('#content').css('width','100%');

//Remove control character from text on Gmail
//
//* Stack Overflow javascript <-> clipboard interaction https://stackoverflow.com/questions/400212
javascript:(()=>{document.addEventListener("copy", function (e) { var copied = window.getSelection().toString(); copied = copied.replace(/[\x0a\x0d]/g, '');e.clipboardData.setData('text/plain', copied);e.preventDefault();});})()
//jQuery version
$(document).on("copy",function (e) { var copied = window.getSelection().toString(); copied = copied.replace(/[\x0a\x0d]/g, '');e.clipboardData.setData('text/plain', copied);e.preventDefault();})


//Remove Copy Guard
// Some Web site disables Ctrl+c or from right click operation by CSS. This bookmarklet reset the css and enable Copy.
$('body').css('-webkit-user-select','initial')

//Highlight token  
//
//* this is useful for Wiki page which doesn't support text highlight very well
//* this highlights particular characters such as "☆" on TODO or conclusion or anything you want to emphasize
//* Highlighting any text starting from "☆" until 全角スペース(%E3%80%80)
$("body").html( $("body").html().replace(/(☆.*?)%E3%80%80/g, '<span style="background-color:#FFCBCE">$1&nbsp;</span>'));$("body").html( $("body").html().replace(/(★.*?)%E3%80%80/g, '<span style="background-color:#FCFFCB">$1&nbsp;</span>'));

