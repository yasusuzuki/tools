/***********************************************************************************************************************
                     Redmine 
************************************************************************************************************************/
// テキストエリア内の現在のカーソル位置に、自分の名前と日付を挿入する
//  参考：フォーカスがあたっているテキストエリア内の現在のカーソル位置にテキストを挿入する方法　https://stackoverflow.com/questions/11076975
javascript:(()=>{
  var ae = document.activeElement;
  var ss = ae.selectionStart;
  var se = ae.selectionEnd;
  var ov = ae.value;
  var name = "※※所属と名前※※";
  document.activeElement.value = ov.substring(0,ss) + new Date().toLocaleDateString() + " " + name + "＞ " + ov.substring(se,ov.length);
})()

/***********************************************************************************************************************
                     Gmail 
************************************************************************************************************************/
// Info block
javascript:(()=>{
  var div = document.createElement("div"); 
  div.setAttribute("style","padding: 5px;border: 1px solid transparent;border-radius: 3px;border-color: #a0c7e4;background-color: #e1ecf4;margin: 0px 20% 0 20px;");
  div.innerText = window.getSelection().toString();
  window.getSelection().getRangeAt(0).deleteContents();
  window.getSelection().getRangeAt(0).insertNode(div);
})()

// Warning block
javascript:(()=>{
  var div = document.createElement("div"); 
  div.setAttribute("style","padding: 5px;border: 1px solid transparent;border-radius: 3px;border-color: #EFE4B1;background-color: #FFFBDD;margin: 0px 20% 0 20px;");
  div.innerText = window.getSelection().toString();
  window.getSelection().getRangeAt(0).deleteContents();
  window.getSelection().getRangeAt(0).insertNode(div);
})()

// Header 
javascript:(()=>{
  var div = document.createElement("h3");
  div.setAttribute("style","border-bottom: 1px solid #ddd; box-shadow: 0.1em 0.4em 0.7em 0 #f2f2f2; padding: 0.2em .3em .1em;");
  div.innerText = window.getSelection().toString();
  window.getSelection().getRangeAt(0).deleteContents();
  window.getSelection().getRangeAt(0).insertNode(div);
})()

// Paste Clipboard with text URL decoded
javascript:(()=>{ 
  navigator.clipboard.readText().then(
    clipText => {
      var div = document.createElement("div");
      div.innerText = decodeURI(clipText);
      window.getSelection().getRangeAt(0).deleteContents();
      window.getSelection().getRangeAt(0).insertNode(div);
    }
  );
})()

/********************************************************************/
https://stackoverflow.com/questions/3997659/replace-selected-text-in-contenteditable-div
function replaceSelectedText(replacementText) {
    var sel, range;
    if (window.getSelection) {
        sel = window.getSelection();
        if (sel.rangeCount) {
            range = sel.getRangeAt(0);
            range.deleteContents();
            range.insertNode(document.createTextNode(replacementText));
        }
    } else if (document.selection && document.selection.createRange) {
        range = document.selection.createRange();
        range.text = replacementText;
    }
}

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


//Remove sidebar panel on Redmine, then remove font-family as Hiragino font doesn't exist
javascript:(function(func) {var scr = document.createElement("script");scr.src = "//ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js";scr.onload = function() {func(jQuery.noConflict(true));};document.body.appendChild(scr);})(function($) {
    $('#sidebar').css({'width':'0%','display':'none'}); $('#content').css('width','100%');
    $('body').css('font-family','');
});


//Remove control character from text on Gmail
//
//* Stack Overflow javascript <-> clipboard interaction https://stackoverflow.com/questions/400212
//https://stackoverflow.com/questions/63187010/e2808b-appears-in-url-net-core
//https://stackoverflow.com/questions/11305797/remove-zero-width-space-characters-from-a-javascript-string
javascript:(()=>{document.addEventListener("copy", function (e) {
   var copied = window.getSelection().toString(); 
   copied = copied.replace(/([\u200B-\u200D\uFEFF])/g, ''); 
   e.clipboardData.setData('text/plain', copied);
   e.preventDefault();
});})()

//Remove Copy Guard
// Some Web site disables Ctrl+c or from right click operation by CSS. This bookmarklet reset the css and enable Copy.
javascript:(function(func) {var scr = document.createElement("script");scr.src = "//ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js";scr.onload = function() {func(jQuery.noConflict(true));};document.body.appendChild(scr);})(function($) {
    $('body').css('-webkit-user-select','initial')
});

//Highlight token  
//
//* this is useful for Wiki page which doesn't support text highlight very well
//* this highlights particular characters such as "☆" on TODO or conclusion or anything you want to emphasize
//* Highlighting any text starting from "☆" until 全角スペース(%E3%80%80)
javascript:(function(func) {var scr = document.createElement("script");scr.src = "//ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js";scr.onload = function() {func(jQuery.noConflict(true));};document.body.appendChild(scr);})(function($) {
    $("body").html( $("body").html().replace(/(☆.*?)%E3%80%80/g, '<span style="background-color:#FFCBCE">$1&nbsp;</span>'));$("body").html( $("body").html().replace(/(★.*?)%E3%80%80/g, '<span style="background-color:#FCFFCB">$1&nbsp;</span>'));
});
