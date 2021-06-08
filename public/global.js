console.log("This is global js file");
function myFunction() {
  console.log("New Project");
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