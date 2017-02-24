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
