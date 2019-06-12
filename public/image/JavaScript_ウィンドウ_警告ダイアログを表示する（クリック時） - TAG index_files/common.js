
// ======================================================

// トグルメニュー
// スクロールトップ

// ======================================================



$(function(){

    var flag = false;



    // グローバルメニュー
    // ======================================================

    // ウィンドウリサイズ時
    $(window).resize(function(){


        if (window.innerWidth > 767) {

            $("#gnav").show();

        } else if (flag == false) {

            $("#gnav").hide();

        }


    });


    // トグルメニュー
    $("#toggle, #close").click(function() {

        if (flag == true) {

            $("body").removeClass("fixed");

            flag = false;

        } else {

            $("body").addClass("fixed");

            flag = true;

        }

        $("#gnav").slideToggle(400);
        $("#toggle").toggleClass("open");

    });



    // スクロール時
    // ======================================================

    $(window).scroll(function() {

        // バックトップボタン
        if ($(window).scrollTop() > 100) {

            $("#backtop").fadeIn();

        } else {

            $("#backtop").fadeOut();

        }

    });



    // スクロールトップ
    // ======================================================

    $("#backtop a").click(function() {

        $("body,html").animate({

            scrollTop: 0

        }, 500);

        return false;

    });



});



