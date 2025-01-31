if (document.images){
  var picNames=new Array("5.png","7.png","9.png","11.png","dot5.png");
  var pics=new Array();   
  for(i=0;i<picNames.length;i++){
    pics.push(new Image());
    pics[i].src=picNames[i];
  }
}