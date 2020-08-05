# My bookmarklet collection

### Code template - How to Load jQuery

```
(function(func) {var scr = document.createElement("script");scr.src = "//ajax.googleapis.com/ajax/libs/jquery/2.0.2/jquery.min.js";scr.onload = function() {func(jQuery.noConflict(true));};document.body.appendChild(scr);})(function($) {   

  //Write your code here
  /Ex.　$('#sidebar').css({'width':'0%','display':'none'}); $('#content').css('width','100%'); 


});
```

### jQuery basics

* $(function(){});  $(document).ready(function{});  jQuery(document).ready(function(){});  jQuery(function(){});
  * https://qiita.com/bakatono_super/items/fcbc828b21599568a597
* jQuery(function($){ ... });と(function($){ ... })(jQuery);の違いを教えて下さい。
  * http://w3q.jp/t/6021
