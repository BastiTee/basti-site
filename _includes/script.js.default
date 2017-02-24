$.fn.extend({
    animateCss: function (animationName) {
        var animationEnd = 'webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend';
        this.addClass('animated ' + animationName).one(animationEnd, function() {
            $(this).removeClass('animated ' + animationName);
        });
    }
});
$('#main-body').animateCss('animated fadeIn');
$('#site-title').animateCss('animated zoomIn');
$('#site-avatar').animateCss('animated zoomIn');
$('#site-bloglist').animateCss('animated slideInLeft');
$('#site-content').animateCss('animated slideInRight');
$('#site-logo').animateCss('animated slideInDown');
$('#post-header').animateCss('animated slideInDown');
$('#post-header-title').animateCss('animated slideInDown');
$('#post-header-meta').animateCss('animated slideInLeft');
$('#post-header-buttonbar').animateCss('animated slideInUp');
$('a[href*="#"]').click(function(){
    var elem = '#fn\\:' + $(this).prop("href").replace(/.*:/, '')
    $(elem).animateCss('animated bounce');
});
