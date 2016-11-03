$(document).ready(function() {
  $('#add-food-modal').on('show.bs.modal', function (event) {
    result = $(event.relatedTarget)
    var brand = result.find(".result-brand").text();
    var name = result.find(".result-name").text();
    var serving_size = result.find(".result-serving-size").text();
    var serving_type = result.find(".result-serving-type").text();
    var calories = result.find(".result-calories").text();
    var fat = result.find(".result-fat").text();
    var carbs = result.find(".result-carbs").text();
    var protein = result.find(".result-protein").text();

    $('<input />').attr('type', 'hidden').attr('name', "brand").attr('value', brand).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "name").attr('value', name).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "calories").attr('value', calories).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "serving-type").attr('value', serving_type).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "serving-size").attr('value', serving_size).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "fat").attr('value', fat).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "carbs").attr('value', carbs).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "protein").attr('value', protein).appendTo('#add-food-form');

    var modal = $(this);
    modal.find('h3').text(brand + " - " + name);
    modal.find('.modal-serving-type').text(serving_type);
    modal.find('p').text("Serving Size: " + serving_size + " " + serving_type)
  })

  $('#edit-food-modal').on('show.bs.modal', function (event) {
    result = $(event.relatedTarget)

    var brand = result.find(".result-brand").text();
    var name = result.find(".result-name").text();
    var serving_size = result.find(".result-serving-size").text();
    var serving_type = result.find(".result-serving-type").text();
    var calories = result.find(".result-calories").text();
    var fat = result.find(".result-fat").text();
    var carbs = result.find(".result-carbs").text();
    var protein = result.find(".result-protein").text();
    var entry_id = result.find(".result-entry-id").text();
    $(".edit-entry-id").text(entry_id);

    $('<input />').attr('type', 'hidden').attr('name', "brand").attr('value', brand).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "name").attr('value', name).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "calories").attr('value', calories).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "serving-type").attr('value', serving_type).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "serving-size").attr('value', serving_size).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "fat").attr('value', fat).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "carbs").attr('value', carbs).appendTo('#add-food-form');
    $('<input />').attr('type', 'hidden').attr('name', "protein").attr('value', protein).appendTo('#add-food-form');

    var modal = $(this);
    modal.find('h3').text(brand + " - " + name);
    modal.find('.modal-serving-type').text(serving_type);
    modal.find('p').text("Serving Size: " + serving_size + " " + serving_type)
  })

  $("#edit-food-form button").click(function(e){
      e.preventDefault();
      entry_id = $(".edit-entry-id").text();
      $("#edit-food-form").attr('action', "/edit-entry/" + entry_id).submit();
  });

  $(".delete-food-btn input[type='submit']").click(function(e) {
    e.stopPropagation();
  });

})
