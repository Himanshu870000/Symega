var skillList = [];
var staffList = [];
function myFunction() {
    debugger;
    var fb = document.getElementById('facebookUrlId');
    fb.href = "https://www.facebook.com/v2.8/dialog/oauth?client_id=" + "{!$Setup.Facebook_API_Details__c.App_Id__c}" + "&response_type=code&redirect_uri=" + "{!$Setup.Facebook_API_Details__c.login_Site_URL__c}" + "&scope=public_profile,email&&auth_type=rerequest";

}
function myFunctionforgoogle() {
    debugger;
    var a = document.getElementById('googleUrlId');
    a.href = "https://accounts.google.com/AccountChooser?continue=https://accounts.google.com/o/oauth2/auth?redirect_uri=" + "{!$Setup.Google_API_Details__c.Login_Redirect_URI__c}" + "%26prompt%3Dconsent%26response_type%3Dcode%26client_id=" + "{!$Setup.Google_API_Details__c.Client_Id__c}" + "%26scope%3Dhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.me%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.profile%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.profile%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.me%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.profile%2Bhttps://www.googleapis.com/auth/plus.login%2Bhttps://www.googleapis.com/auth/plus.me%2Bhttps://www.googleapis.com/auth/userinfo.email%2Bhttps://www.googleapis.com/auth/userinfo.profile%2Bhttps://www.googleapis.com/auth/userinfo.email%26access_type%3Doffline%26from_login%3D1%26as%3D-270badd61a3e150b&btmpl=authsub&scc=1&oauth=1";
}

var app = angular.module('LoginApp', []);
app.controller('LoginCtlr', function ($scope) {
    debugger;
    $scope.userName = '';
    $scope.userPassword = '';
    $scope.registrationPage = false;
    $scope.skillList = skillList;
    $scope.staffList = staffList;
    $scope.isRegistration = isRegistration;
    
    $scope.verifyEmail; 
    $scope.showSpinner = false;
    if(isRegistration == "true"){
        $scope.registrationPage = true;
    }else{
        $scope.registrationPage = false;
    }

    $scope.loginUser = function () {
        console.log('Username',$scope.userName);
        console.log('userPassword',$scope.userPassword);
        // $scope.userPassword;

        $scope.showSpinner = true;
        Distributor_LoginPage_Controller.loginUser($scope.userName, $scope.userPassword, function (result, event) {
            if (event.status && result != null) {
                $scope.Profile = result;
                $scope.hashcodeId = $scope.Profile.Login_Hash_Code__c;
                $scope.userLoggedIn = true;
                Swal.fire(
                    '',
                    'LoggedIn Successfully!',
                    'success'
                  )
                $scope.$apply();
                debugger;
                if(result.Status__c == "Document Submission"){
                    window.location.replace(siteUrl+"documentUpload?hc="+$scope.Profile.Login_Hash_Code__c);
                    return;
                }
                //window.location.replace(siteUrl+"DistributorDashboard?hc=" + $scope.Profile.Login_Hash_Code__c+'#/CP_HomePage');
                window.location.replace(siteUrl+"DistributorDashboard?hc=" + $scope.Profile.Login_Hash_Code__c+'#/Home');
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Oops...',
                    text: 'Please enter the correct Username and Password!'
                })
            }
        }, { escape: false })
        $scope.showSpinner = false;
        $scope.$apply();
    }

    $scope.showRegForm = function(){
        $scope.registrationPage = true;
    }
    $scope.selectedStaffType = [];
    $scope.staffTypePickValue = function(staff){
        debugger;
        if($scope.selectedStaffType.includes(staff)){
            
            $scope.selectedStaffType.splice($scope.selectedStaffType.indexOf(staff),1);
        }else{
            $scope.selectedStaffType.push(staff);
        }
    }

    $scope.backToLoginPage = function(){
        debugger;
        $scope.registrationPage = false;        
    }

    $scope.checkForEmail = function(){
        $scope.showSpinner = true;
        Distributor_LoginPage_Controller.verifyEmail($scope.verifyEmail ,function(result,event){
            if(event.status){ // && result != null
                debugger;
              if(result != null){
                Swal.fire(
                    '',
                    'Password reset link sent to your registered Email Successfully!',
                    'success'
                  )
              }
            }
            else{
              
            }
        },{escape:false})
        $scope.showSpinner = false;
    }
});