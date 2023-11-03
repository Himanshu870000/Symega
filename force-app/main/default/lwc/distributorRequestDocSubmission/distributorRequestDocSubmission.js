import { api, LightningElement } from 'lwc';
import sendResetPasswordEmail from '@salesforce/apex/DistributorInternalUtility.sendResetPasswordEmail';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class DistributorRequestDocSubmission extends NavigationMixin(LightningElement) {

    @api recordId;
    displayText = 'Please wait, sending email notification to Distributor.';
    connectedCallback() {
        setTimeout(() => this.sendEmail(), 2000);
    }

    sendEmail() {
        sendResetPasswordEmail({ distributorId: this.recordId })
            .then(result => {
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'Email sent successfully.',
                    variant: 'success',
                });
                this.dispatchEvent(event);
                this.closeAction();
            })
            .catch(error => {
                this.displayText = error;
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong, please contact System Administrator.',
                    variant: 'error'
                });
                this.dispatchEvent(event);
            });
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
        //this.navigateToRecordViewPage();
        setTimeout(() => window.location.reload(), 2000);

    }

    navigateToRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Contact', // objectApiName is optional
                actionName: 'view'
            }
        });
    }

}