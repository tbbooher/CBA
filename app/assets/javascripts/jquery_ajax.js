$(function() {
  $("#legislators_table.haml th a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
});