// Two relevant events: mousedown, mouseup

stop_condition = -1;

function increment(txt)
{
  clearInterval(stop_condition);
  var v = Number($('#'+txt).attr('value'));
  up_iteration = 0;
  stop_condition = setInterval( function(){
    if(up_iteration < 4){
      v += 0.5;
      $('#'+txt).attr('value', v);
      up_iteration +=1;
    }
    else{
      v += 1;
      $('#'+txt).attr('value', v);
      up_iteration +=1;
    }
  }, 500);
}

function decrement(txt)
{
  clearInterval(stop_condition);
  var v = Number($('#'+txt).attr('value'));
  up_iteration = 0;
  stop_condition = setInterval( function(){
    if(up_iteration < 4){
      v -= 0.5;
      $('#'+txt).attr('value', v);
      up_iteration +=1;
    }
    else{
      v -= 1;
      $('#'+txt).attr('value', v);
      up_iteration +=1;
    }
  }, 500);
}

$(document).ready( function(){

$('#up_btn').on('mousedown', function() { increment("temp");     } );
$('#up_btn').on('mouseup',   function() { clearInterval(stop_condition); } );
$('#up_btn').on('click',     function() { v = Number($('#temp').attr('value')) + 0.5 ; $('#temp').val(v); } );


$('#down_btn').on('mousedown', function() { decrement("temp");     } );
$('#down_btn').on('mouseup',   function() { clearInterval(stop_condition); } );
$('#down_btn').on('click', function() { newVal = Number($('#temp').attr('value')) - 0.5 ; $('#temp').attr('value',newVal);} );



});
