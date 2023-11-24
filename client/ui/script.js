var executes = {}
window.addEventListener("message", (event) => {
    try {
        executes[event.data.action](event.data)
    } catch (error) {
        console.log(event.data.action)
        console.log(error)
    }
})

document.addEventListener("keydown", function (event) {
    if (event.key === "Escape" || event.key === "Backspace") {
        CloseUI()
    }
});

$("html").click(function(e) {
    if ($(e.target).parents("#menu").length == 0) {
        CloseUI()
    }
})

function CloseUI() {
    $(".active").removeClass("active")
    $.post("http://exp_target_menu/Close")
}

executes["SHOW_CURSOR"] = function(data) {
    if (data.toggle) {
        $("#cursor").css("display", "flex")
    } else {
        $("#cursor").css("display", "none")
        $(".entity").remove()
    }
}

executes["SET_CURSOR_ACTIVE"] = function(data) {
    data.toggle ? $("#cursor").addClass("active") : $("#cursor").removeClass("active")
}

executes["OPEN_MENU"] = function(data) {
    $("#menu-title-text").html(data.title)
    $("#cursor").addClass("active")
    $("#menu-list").html("")
    data.options = SortByKeys(data.options)

    var item_count = 0
    for (const [key, value] of Object.entries(data.options)) {
        if (!value.desc) continue
        
        item_count++
        const item = $(`<div class="menu-item">${value.desc}</div>`)
        
        item.click(function() {
            $.post("http://exp_target_menu/Trigger", JSON.stringify({
                event: key,
                data: value
            }))
            if (value.stay != true) CloseUI()
        })

        item.mouseover(function() {
            const audio = new Audio("sounds/hover_sound.mp3")
            audio.volume = 0.3
            audio.play()
        })

        $("#menu-list").append(item)

        setTimeout(() => {
            item.addClass("active")
        }, item_count*50);
    }
    $("#menu").addClass("active")
    setTimeout(() => {
        $("#menu-line").addClass("active")
        $("#menu-title-text").addClass("active")
    }, 0);
}

function SortByKeys(dict) {

    var sorted = [];
    for(var key in dict) {
        sorted[sorted.length] = key;
    }
    sorted.sort();

    var tempDict = {};
    for(var i = 0; i < sorted.length; i++) {
        tempDict[sorted[i]] = dict[sorted[i]];
    }

    return tempDict;
}

executes["FORCE_CLOSE"] = function(data) {
    CloseUI()
}