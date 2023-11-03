angular.module('cp_app').controller('editProfile_ctrl', function ($scope,$rootScope, $log, $timeout) {
    debugger;
	console.log($rootScope.profilePicId)
    $rootScope.userDetails;
    $scope.profilePic = true;
    $scope.contactUserDocument = [];
    $rootScope.blobData;
    $scope.showSpinnereditProf = false;
    $scope.resumeIframe = "data:application/pdf;base64,"+$rootScope.blobData;
    $rootScope.blobData;
    $scope.showSpinnereditProf = false;
    $rootScope.temShiftSpecialSkills;
    $rootScope.crownPicklistVal;
    $scope.compSkillPickVal = $rootScope.compSkillPickVal;
    $scope.staftypePickVal = $rootScope.staffList;
    $scope.pmsKnowledgePickval = $rootScope.pmsSkillPickVal;
    $scope.xrayProficiencyPickVal = $rootScope.xrayProficiencyPickVal;
    $scope.imgSoftwarePickVal = $rootScope.imgeSoftwarePickVal;
    $rootScope.profilePicUD='';
    $scope.profilePicURL = '';
    
    var input = document.getElementById('resumeAttachmentFile');
    var infoArea = document.getElementById('file-upload-filename');
    debugger;
    document.querySelector('input.dropzone').addEventListener( 'change', showFileName );

    function showFileName( event ) {
        var input = event.srcElement;
        var fileName = input.files[0].name;
        infoArea.textContent = 'File name: ' + fileName;
    }

    $scope.showFileName = function(){}

    $scope.getExperienceDetail = function () {
        $scope.showSpinnereditProf = true;
        DistributorDashboard_Controller.getAllWorkExperience($rootScope.candidateId, function (result, event) {
            if (event.status && result != null) {
                $scope.prevExprience = result;
                $scope.$apply();
            }
        }, { escape: false })
        $scope.showSpinnereditProf = false;
    }

    $scope.changeProfilePic = function () {
        $scope.profilePic = false;
    }

    $scope.uploadProfilePic = function () {
        debugger;
        $scope.uploadFile("profilePic", "", $rootScope.profilePicUD.userDocument.Id);
    }

    $scope.selUserDocId = function (fileId,doc) {
        $scope.showUplaodUserDoc = true;
        $scope.fileId = fileId;
        $scope.selecteduDoc = doc;
    }

    $scope.backFromUploadDoc = function () {
        $scope.showUplaodUserDoc = false;
        $scope.fileId = '';
        $scope.selecteduDoc = '';
    }
    $scope.uploadFileToUserDoc = function (type) {
       debugger;
        $scope.selecteduDoc;
        
        if($scope.fileId != undefined){
            $scope.uploadFile(type, $scope.selecteduDoc, $scope.fileId);
        }else {
            if (type == 'resume') {
                if ($rootScope.resumeUserDoc.contentVersion != undefined) {
                    $scope.uploadFile(type, $rootScope.resumeUserDoc.userDocument.Id, $rootScope.resumeUserDoc.contentVersion.Id);
                } else {
                    $scope.uploadFile(type, $rootScope.resumeUserDoc.userDocument.Id, "");
                }
            } else if(type == 'profilePic'){
                $scope.uploadFile(type, $rootScope.resumeUserDoc.Id, "");
            }
            else {
                $scope.uploadFile(type, $scope.selecteduDoc, "");
            }
        }
     
    }

    	
    $scope.getUserDetails=function(){
        DistributorDashboard_Controller.getDistributorDetails(candidateId,function(result,evt){
            debugger;
            console.log(result);
            if(result.Profile_Pic_Id__c){
                $scope.profilePicURL = `https://symegafood--symegadev.lightning.force.com/sfc/servlet.shepherd/version/download/${result.Profile_Pic_Id__c}`
                $rootScope.profilePicId = result.Profile_Pic_Id__c;
            }else{
                $scope.profilePicURL = 'https://icons-for-free.com/download-icon-business+costume+male+man+office+user+icon-1320196264882354682_512.png'
            }
            $scope.userDetails=result;
        })
    }

    $scope.getUserDetails();
    
    $scope.getContactUserDoc = function () {
        debugger;
        $scope.contactUserDocument = [];
        $scope.showSpinnereditProf = true;
        DistributorDashboard_Controller.getContactUserDoc(candidateId, function (result, event) {

            if (event.status && result != null) {
                debugger;
                console.log(result);
                for (var i = 0; i < result.length; i++) {
                    if (result[i].userDocument.Name == "Profile Picture") {
                        console.log(result[i])
                        $rootScope.profilePicUD = result[i];
                    } else if (result[i].userDocument.Name == "Resume") {
                        $rootScope.resumeUserDoc = result[i];
                        if($rootScope.resumeUserDoc.contentVersion != null){
                            $rootScope.updateResume = false;
                        }
                    } else {
                        $scope.contactUserDocument.push(result[i]);
                    }
                }
                $scope.$apply();
            }
        }, { escape: false })
        $scope.showSpinnereditProf = false;
    }

    $scope.getContactUserDoc();

    $scope.getUserDoc = function () {
        debugger;
        $scope.showSpinnereditProf = true;
        DistributorDashboard_Controller.getAllUserDoc($rootScope.candidateId, function (result, event) {
            if (event.status && result != null) {
                debugger;
                console.log(result);
                for (var i = 0; i < result.length; i++) {
                    if (result[i].userDocument.Name == "Profile Picture") {
                        $rootScope.profilePicUD = result[i];
                    } else if (result[i].userDocument.Name == "Resume") {
                        $rootScope.resumeUserDoc = result[i];
                        if($rootScope.resumeUserDoc.contentVersion != null){
                            $rootScope.updateResume = false;
                        }
                    } else {
                        $scope.contactUserDocument.push(result[i]);
                    }
                }
                $scope.$apply();

            }
        }, { escape: false })
        $scope.showSpinnereditProf = false;
    }

    $scope.uploadFile = function (type, userDocId, fileId) {
        debugger;
        $scope.showSpinnereditProf = true;
        var file;
        if (type == 'profilePic') {
            file = document.getElementById('profilePic').files[0];
        } else if (type == 'resume') {
            file = document.getElementById('resumeAttachmentFile').files[0];
        }
        else {
            file = document.getElementById('attachmentFiles').files[0];
        }

        console.log(file);
        if (file != undefined) {
            if (file.size <= maxFileSize) {
                
                attachmentName = file.name;
                const myArr = attachmentName.split(".");
                if (myArr[1] != "pdf" && type != 'profilePic') {
                    alert("Please upload in PDF format only");
                    return;
                }
                var fileReader = new FileReader();
                fileReader.onloadend = function (e) {
                    attachment = window.btoa(this.result);  //Base 64 encode the file before sending it
                    positionIndex = 0;
                    fileSize = attachment.length;
                    $scope.showSpinnereditProf = false;
                    console.log("Total Attachment Length: " + fileSize);
                    doneUploading = false;
                    debugger;
                    if (fileSize < maxStringSize) {
                        $scope.uploadAttachment(type , userDocId, fileId);
                    } else {
                        alert("Base 64 Encoded file is too large.  Maximum size is " + maxStringSize + " your file is " + fileSize + ".");
                    }

                }
                fileReader.onerror = function (e) {
                    alert("There was an error reading the file.  Please try again.");
                }
                fileReader.onabort = function (e) {
                    alert("There was an error reading the file.  Please try again.");
                }

                fileReader.readAsBinaryString(file);  //Read the body of the file

            } else {
                alert("File must be under 4.3 MB in size.  Your file is too large.  Please try again.");
                $scope.showSpinnereditProf = false;
            }
        } else {
            alert("You must choose a file before trying to upload it");
            $scope.showSpinnereditProf = false;
        }
    }

    $scope.uploadAttachment = function (type, userDocId, fileId) {
        var attachmentBody = "";
        if (fileId == undefined) {
            fileId = " ";
        }
        if (fileSize <= positionIndex + chunkSize) {
            debugger;
            attachmentBody = attachment.substring(positionIndex);
            doneUploading = true;
        } else {
            attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
        }
        console.log("Uploading " + attachmentBody.length + " chars of " + fileSize);
        DistributorDashboard_Controller.doUploadAttachment(
            type, attachmentBody, attachmentName, candidateId, userDocId,fileId, 
            function (result, event) {
                debugger;
                console.log(result);
                if (event.type === 'exception') {
                    console.log("exception");
                    console.log(event);
                } else if (event.status) {
                    if (doneUploading == true) {
                        if (type == 'profilePic') {
                            $rootScope.profilePicId = result;
                            $scope.profilePic = true;
                            Swal.fire(
                                '',
                                'Uploaded Successfully!',
                                'success'
                            )

                            $scope.profilePicURL = `https://symegafood--symegadev.lightning.force.com/sfc/servlet.shepherd/version/download/${result}`
                            $rootScope.profilePicId = result

                            $scope.$apply();
                        } else if (type == 'resume') {
                            $("#resumeUploadModel").modal('hide');
                            $scope.parseResume(result);
                            $rootScope.updateResume = false;
                        }else{
                            Swal.fire(
                                '',
                                'Uploaded Successfully!',
                                'success'
                            )
                            $("#fileUploadModel").modal('hide');
                            
                            
                            $scope.getContactUserDoc();
                        }
                        $scope.showUplaodUserDoc = false;
                       // $scope.getCandidateDetails();

                    } else {
                        debugger;
                        positionIndex += chunkSize;
                        $scope.uploadAttachment(type,userDocId,result);
                    }
                } else {
                    console.log(event.message);
                }
            },


            { buffer: true, escape: true, timeout: 120000 }
        );
    }

    $scope.getResumeDetail = function(){
        
    }

    $scope.educationDetails = [];
    $scope.experienceDetails = []; 

    console.log($scope.userDetails);

    $scope.updateUserDetails = function () {
        $scope.showSpinnereditProf = true;
        DistributorDashboard_Controller.updateUserDetails($scope.userDetails, function (result, event) {
            console.log("Result----",result);
            
            if (event.status) {
                
                $scope.editProfile = true;
                Swal.fire(
                    '',
                    'Updated successfully!',
                    'success'
                )
            $scope.showSpinnereditProf = false;
            }
            else {
            $scope.showSpinnereditProf = false;
            }
            $scope.$apply();
        }, { escape: false })
    }

    $scope.viewDocument = function (doc) {
        debugger; 
        if(doc && doc.ContentDistribution && doc.ContentDistribution.DistributionPublicUrl)
        window.open(doc.ContentDistribution.DistributionPublicUrl);
    }

    $scope.editProfileFunc = function () {
        debugger;
        $scope.editProfile = false;
    }
    
    $scope.example14data = [];
    $scope.cityInSelectedCounty = function(){
        $scope.example14data = [];
        console.log('$scope.selectedCounty::'+$scope.selectedCounty);
        DistributorDashboard_Controller.getAllCityInCounty($scope.selectedCounty,$scope.selectedCityList, function (result, event) {
            if (event.status) {
                debugger;
               // $scope.cityList = result;
               if(result.length > 0){
                   for(var i=0;i<result.length;i++){
                    $scope.example14data.push({
                        "label":result[i].Name ,
                            "id": result[i].Id
                    });
                   }
               }
              // $scope.example14data = result;
            }
            else {
            }
        }, { escape: false })
    }

    $scope.selectedCityList = [];
    $scope.getPreferredWorkingLocation = function(){
        $scope.selectedCityList = [];
        DistributorDashboard_Controller.getPreferredWorkingLocation($rootScope.candidateId, function (result, event) {
            if (event.status) {
                $scope.prefWorkLocation = result;
                if($scope.prefWorkLocation != undefined){
                    for(var i=0;i<$scope.prefWorkLocation.length;i++){
                        $scope.selectedCityList.push($scope.prefWorkLocation[i].City__c); 
                    }
                }
                $scope.$apply();
                debugger;
              
            }
            else {
            }
        }, { escape: false })
    }
    //$scope.getPreferredWorkingLocation();


    $scope.saveCandidateResumeDetails = function(){
        
        $scope.showSpinnereditProf = true;
        if($scope.educationDetails.length > 0){
            for(var i=0; i<$scope.educationDetails.length;i++){
                delete $scope.educationDetails[i].$$hashKey;
                delete $scope.educationDetails[i].End_Year__c;
            }
        }

        if($scope.experienceDetails.length > 0){
            for(var i=0; i<$scope.experienceDetails.length;i++){
                delete $scope.experienceDetails[i].$$hashKey;
                delete $scope.experienceDetails[i].Start_Date__c;
                delete $scope.experienceDetails[i].End_date__c;
            }
        }
        DistributorDashboard_Controller.saveResumeResponse($scope.educationDetails,$scope.experienceDetails, function (result, event) {
            if (event.status) {                
                Swal.fire(
                    '',
                    'Candidate Details Saved Successfully!',
                    'success'
                )
               /* document.getElementById("resumeParsing").click();  
                document.getElementById("candDetailPopup").click(); */
                $scope.showResumeParser = false;
                $scope.$apply();
                
            }
            
        }, { escape: false })
        $scope.showSpinnereditProf = false;
    }
});