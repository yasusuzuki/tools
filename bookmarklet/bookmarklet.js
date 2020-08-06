

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

