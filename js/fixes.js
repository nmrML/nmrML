$( document ).ready(function(){

  fill_with_iframe = function(){
    navbar_height = $("div.navbar").height();
    window_height = $(window).height();

    $('.iframewrap iframe').height(window_height - navbar_height);
  }

  fill_with_iframe();
  $( window ).resize(fill_with_iframe);

});
