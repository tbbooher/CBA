$(function() {
  $("#legislators_table th a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
});