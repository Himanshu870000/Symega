
var tabValues = [];
var workingDaysValues = [];
var userId;
var siteURL;
var candidateId;
var getAllEvents;
var eventsOnLoad;
var maxStringSize = 6000000;    //Maximum String size is 6,000,000 characters
var maxFileSize = 4350000;      //After Base64 Encoding, this is the max file size
var chunkSize = 950000;         //Maximum Javascript Remoting message size is 1,000,000 characters
var attachment;
var attachmentName;
var fileSize;
var positionIndex;
var doneUploading;
var blobData;

var app = angular.module('cp_app');
//debugger;
var sitePrefix =  '/apex'; 
app.config(function ($routeProvider, $locationProvider) {
    debugger
    //debugger;
    $locationProvider.html5Mode(false).hashPrefix('');
    var rp = $routeProvider;    
    for (var i = 0; i < tabValues.length; i++) {
		//debugger;
        console.log('TabValues-----',tabValues[i].Name);
        var pageName = '/' + tabValues[i].Name;

        if (tabValues[i].Controller_Name__c != undefined) {
            console.log(tabValues[i].Controller_Name__c);
            rp.when(pageName, {

                templateUrl: sitePrefix + pageName,
                controller: tabValues[i].Controller_Name__c
            });
        } else {
            rp.when(pageName, {
                templateUrl: sitePrefix + pageName,
            })
        }

    }
});




app.controller('cp_dashboard_ctrl', function ($scope, $rootScope, $timeout, $window, $location, $element) {
    
    $scope.tabValues = tabValues;
    $scope.profilePic = profilePic;


    $scope.logout = function () {
        DistributorDashboard_Controller.LogoutClass(candidateId, function (result, event){
                window.location.replace(domainURL+"Distributor_LoginPage");
                if(event.status){
                    $scoope.$apply();
                }else if(event.type === 'exception'){  
                }
            },
           {escape: true}
          );
    }
});  