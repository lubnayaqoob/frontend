function myFunctionok(){
  console.log("text print");
  var weight = document.querySelector("#weight").value;
  var pickUpLocation = document.querySelector("#pickUpLocation").value;
  var dropOffLocation = document.querySelector("#dropOffLocation").value;

  var searchPrams = {
    weight: weight,
    pickUpLocation: pickUpLocation,
    dropOffLocation: dropOffLocation,
  };
  console.log(searchPrams);

}
