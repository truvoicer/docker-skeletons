
// Update the content of the page
function replace_shortcode_before_display($content)
{
    $url = get_bloginfo('url');
    $stylesheetUrl = get_stylesheet_directory_uri();
    $content = str_replace(
        [
            'src="[get_bloginfo]url[/get_bloginfo]',
            'href="[get_bloginfo]url[/get_bloginfo]',
            "url('[get_bloginfo]url[/get_bloginfo]",
            "url([get_bloginfo]url[/get_bloginfo]",
        ],
        [
            'src="' . $stylesheetUrl,
            'href="' . $url,
            "url('" . $stylesheetUrl,
            "url(" . $stylesheetUrl,
        ],
        $content
    );
    return preg_replace('/\[get_bloginfo\]url\[\/get_bloginfo\]/is', $stylesheetUrl, $content);
}
add_filter('the_content', 'replace_shortcode_before_display');