# My bookmarklet collection

### Code template - How to Load jQuery

```
(function(func) {var scr = document.createElement("script");scr.src = "//ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js";scr.onload = function() {func(jQuery.noConflict(true));};document.body.appendChild(scr);})(function($) {   

  //Write your code here
  /Ex.　$('#sidebar').css({'width':'0%','display':'none'}); $('#content').css('width','100%'); 


});
```
