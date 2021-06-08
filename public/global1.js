console.log('This is global js file');
function getValues(){
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

function search1() {
  const thisForm = document.getElementById('#formSubmit');
  getValues()
  options = {
    method : 'POST',
    body : JSON.stringify(data)


  }

  fetch('/api', options);
  
  }


  const search = () => {
    loadMessageData = true;
    $("#charts-section").html('');
    var alreadyProcessedItems = [];
    var chartsObj = processedInformation.parsedMessages;

    for (var counter = 0; counter < chartsObj.length; counter++) {
        var chartDataArray = [];
        var newChartArray = [];
        var uniqueItems = [];

        if (alreadyProcessedItems.includes(chartsObj[counter].id)) {
            return;
        }

        alreadyProcessedItems.push(chartsObj[counter].id);

        FilterDataAndDrawChart(chartsObj, counter, chartDataArray);
    }
};