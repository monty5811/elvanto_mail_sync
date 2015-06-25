function change_global(p_id, disabled_boolean) {
      $.ajax({
            url : '/buttons/update_global/',
            type : "POST",
            data : {'method':'update_global', 'p_id': p_id, "disabled_boolean": disabled_boolean},
            success : function(json) {
                if (disabled_boolean > 0) {
                    $('#global-'+json.pk).html('<div id=global-'+json.pk+'><button type="button" class="btn btn-danger" onclick="enable_global('+json.pk+')">Globally Disabled</button></div>')
                } else {
                    $('#global-'+json.pk).html('<div id=global-'+json.pk+'><button type="button" class="btn btn-success" onclick="disable_global('+json.pk+')">Globally Enabled</button></div>')
                }
            },
            error : function(xhr,errmsg,err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
}
function enable_global(p_id) {change_global(p_id, 0)}
function disable_global(p_id) {change_global(p_id, 1)}

function change_local(g_id, p_id, disabled_boolean) {
      $.ajax({
            url : '/buttons/buttons/update_local/',
            type : "POST",
            data : {'method':'update_local', 'g_id':g_id, 'p_id': p_id, "disabled_boolean": disabled_boolean},
            success : function(json) {
                if (disabled_boolean > 0) {
                    $('#local-'+json.p_pk).html('<div id=local-'+json.pk+'><button type="button" class="btn btn-danger" onclick="enable_local('+json.g_pk+', '+json.p_pk+')">Disabled</button></div>')
                } else {
                    $('#local-'+json.p_pk).html('<div id=local-'+json.pk+'><button type="button" class="btn btn-success" onclick="disable_local('+json.g_pk+', '+json.p_pk+')">Enabled</button></div>')
                }
            },
            error : function(xhr,errmsg,err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
}
function enable_local(g_id, p_id) {change_local(g_id, p_id, 0)}
function disable_local(g_id, p_id) {change_local(g_id, p_id, 1)}


function push_or_pull(img_, url_) {
    var original_html = $('#buttons-all').html();
    $('#buttons-all').html('<img height="15" src="'+img_+'">');
    $.ajax({
            url : url_,
            type : "POST",
            data : {'method':''},
            success : function(json) {
                $('#buttons-all').html('<p>Your request is being processed, this may take a couple of minutes, please be patient.</p>');
            },
            error : function(xhr,errmsg,err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
};

function push_grp(img_, url_, g_id) {
    var original_html = $('#buttons-all').html();
    $('#buttons-all').html('<img height="15" src="'+img_+'">');
    $.ajax({
            url : url_,
            type : "POST",
            data : {'g_id':g_id},
            success : function(json) {
                $('#buttons-all').html('<p>Your request is being processed, this may take a couple of minutes, please be patient.</p>');
            },
            error : function(xhr,errmsg,err) {
                console.log(xhr.status + ": " + xhr.responseText);
            }
        });
};
// This function gets cookie with a given name
function getCookie(name) {
    var cookieValue = null;
    if (document.cookie && document.cookie != '') {
        var cookies = document.cookie.split(';');
        for (var i = 0; i < cookies.length; i++) {
            var cookie = jQuery.trim(cookies[i]);
            // Does this cookie string begin with the name we want?
            if (cookie.substring(0, name.length + 1) == (name + '=')) {
                cookieValue = decodeURIComponent(cookie.substring(name.length + 1));
                break;
            }
        }
    }
    return cookieValue;
}
var csrftoken = getCookie('csrftoken');

/*
The functions below will create a header with csrftoken
*/

function csrfSafeMethod(method) {
    // these HTTP methods do not require CSRF protection
    return (/^(GET|HEAD|OPTIONS|TRACE)$/.test(method));
}
function sameOrigin(url) {
    // test that a given url is a same-origin URL
    // url could be relative or scheme relative or absolute
    var host = document.location.host; // host + port
    var protocol = document.location.protocol;
    var sr_origin = '//' + host;
    var origin = protocol + sr_origin;
    // Allow absolute or scheme relative URLs to same origin
    return (url == origin || url.slice(0, origin.length + 1) == origin + '/') ||
        (url == sr_origin || url.slice(0, sr_origin.length + 1) == sr_origin + '/') ||
        // or any other URL that isn't scheme relative or absolute i.e relative.
        !(/^(\/\/|http:|https:).*/.test(url));
}

$.ajaxSetup({
    beforeSend: function(xhr, settings) {
        if (!csrfSafeMethod(settings.type) && sameOrigin(settings.url)) {
            // Send the token to same-origin, relative URLs only.
            // Send the token only if the method warrants CSRF protection
            // Using the CSRFToken value acquired earlier
            xhr.setRequestHeader("X-CSRFToken", csrftoken);
        }
    }
});
