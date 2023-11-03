public class Constants {
    public static final String OPP_PARENT_RECORD_TYPE = 'Parent';
    public static final String OPP_CHILD_RECORD_TYPE = 'One Time';
    public static final string LEAD_APPROVAL = 'Lead Approval';
    
    public static final String COUNTRY_INDIA = 'India';

    public static final String COLOR_API_NAME = 'Natural colour';
    public static final String FLAVOUR_API_NAME = 'FLAVOUR';
    public static final String FAMILY_CPD = 'CPD';
    public static final String FAMILY_SPD = 'SPD';
    public static final String FAMILY_PLANT_BASED = 'PLANT BASED';


    public static final string PENDING = 'Pending';
    public static final string SAP_PLANT_BASED_FAMILY_MAPPING_VALUE = 'SFD';
    public static final string LEAD_STATUS_QUALIFIED = 'Qualified';
    public static final string LEAD_STATUS_NURTURING = 'Nurturing';  
    public static final string REJECTED_STAGE = 'Dormant / Rejected';
    public static final string ACCEPTED_BY_MH_STATUS = 'Marketing Qualification';
    public static final string ACCEPTED_BY_BH_STATUS = 'Sales Qualification';
    public static final string LEAD_STAGE_UNDER_APPROVAL = 'Under Approval';
    public static final string PROJECT_APPROVAL_TYPE = 'Project Approval';
    public static final string PROJECT_APPROVAL_PROCESS = 'Project_Approval_Process';
    public static final string LEAD_APPROVAL_PROCESS_MH = 'Lead_Nurture_Approval'; 
    public static final string LEAD_APPROVAL_PROCESS_BH = 'Lead_Approval_BH';
    public static final string ACCEPTED_BY_MH_SUBSTAGE = 'Accepted by Marketing Head'; 
    public static final string REJECTED_BY_MH_SUBSTAGE = 'Rejected by Marketing Head'; 
    public static final string ACCEPTED_BY_BH_SUBSTAGE = 'Accepted by Business Head'; 
    public static final string REJECTED_BY_BH_SUBSTAGE = 'Rejected by Business Head'; 
    public static final string BH_APPROVAL_GROUP = 'Lead Approval Business Head';
    public static final string MH_APPROVAL_GROUP = 'Lead Approval Marketing Head';
    public static final string ContactRecordTypeProductMember = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Product Member').getRecordTypeId();
    public static final string OpportunityRecordTypeOneTime = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('One Time').getRecordTypeId();
    public static final string OPPOTUNITY_STAGE_CLOSED_WON = 'Closed Won'; 
    public static final String LEAD_BUSINESS_HEAD_REQ_ERROR_MSG = 'Please add business head in-order to proceed';
    public static final String LEAD_SEGMENT_REQ_BY_MH_ERROR_MSG = 'Please provide Lead segment in-order to proceed';
    public static final String LEAD_APPROVAL_STATUS_MH_APPROVED = 'Approved By Marketing Head';
    public static final String LEAD_APPROVAL_STATUS_BH_APPROVED = 'Approved By Business Head';
    public static final String OPP_ACC_TEAM_MEMBER_VALIDATION_MSG = System.Label.Opportunity_Accont_Team_Validation_Message;
    public static final String OPP_UNDER_APPROVAL_PROCESS_ERR_MSG = System.Label.Opportunity_MarkDown_Error_Msg;
   
    
    // These variables are introduced with respect to Distributor portal
    public static string DISTRIBUTOR_SITE             = System.label.SymegaSiteURL;
    public static final String DISTRIBUTOR            = 'Distributor';
    public static final String TEMP_URL_SENT_CONFIRMATION    = 'Temporary URL sent successfully';
    public static final String ERROR_MSG    = 'Error';
    public static final String CONTACT_SYMEGA    = 'Some Error Occurred - Please Contact your Symega Team !!!';
    public static final String ReferalEmailTemplate    = 'Referral_Email_to_Distributor';

    //OppLineItem Error messages
    public static final String LINE_ITEM_PACKAGING_TYPE_RESTRICTION_ERR_MSG = System.Label.OLI_PACKTYPE_RESTRICT_ERR_MSG;
    public static final String LINE_ITEM_ADDITION_RESTRICTION_ERR_MSG = System.Label.OLI_ADDITION_RESTRICT_ERR_MSG;
    
    //Quote Error Message
    public static final String QuoteCreationErrorMsg = System.Label.Quote_Creation_Error;

    //Portal Constants
    public static final String CHANNEL_SALES_PB = 'Channel Sales';
    
    //Return Qty greater than Opp Prod Error Message
    public static final String QTY_ERROR = 'Return quantity cannot be greater than the Opportunity Product quantity.';
    
    public static final string RETURN_APPROVAL_PROCESS = 'Return_Approval_Process';

    public static final String SO_CREATION_SUCCESS_RESPONSE = System.label.SO_CREATION_SUCCESS_RESPONSE;
    public static final String CUSTOMER_CODE_EMPTY_ERROR = System.label.CUSTOMER_CODE_EMPTY_ERROR;
    public static final String INVALID_FERT_CODE_ERROR = System.label.INVALID_FERT_CODE_ERROR;
    public static final String FERT_CODE_NOT_FOUND_ERROR = 'Fert code not found for requested product';

    
    public static final String OPTIVA_AUTH_HEADER = System.Label.OPTIVA_AUTH_HEADER;
    public static final String OPTIVA_CUSTOMER_CREATION_AUTH_HEADER = System.Label.OPTIVA_CUSTOMER_CREATION_AUTH_HEADER;
    public static final String OPTIVA_SYNCING_ENABLE_MSG = 'Optiva syncing is disable';
    public static final String OPTIVA_NO_RESPONSE_MSG= System.Label.OPTIVA_NO_RESPONSE_MSG;

    public static final String OPTIVA_CREATE_CUSTOMER_ENDPOINT = System.label.OPTIVA_CREATE_CUSTOMER_ENDPOINT;
    public static final String OPTIVA_CREATE_PROJECT_ENDPOINT = System.label.OPTIVA_CREATE_PROJECT_ENDPOINT;

    public static final String SAP_CREATE_CUSTOMER_REQ_TOKEN = System.label.SAP_CREATE_CUSTOMER_REQ_TOKEN;
    public static final String SAP_CREATE_CUSTOMER_ENDPOINT = System.label.SAP_CREATE_CUSTOMER_ENDPOINT;

    public static final String SAP_UPDATE_CUSTOMER_REQ_TOKEN = System.label.SAP_UPDATE_CUSTOMER_REQ_TOKEN;
    public static final String SAP_UPDATE_CUSTOMER_ENDPOINT = System.label.SAP_UPDATE_CUSTOMER_ENDPOINT;

    

    public static final String SAP_CREATE_PROJECT_REQ_TOKEN = System.label.SAP_CREATE_PROJECT_REQ_TOKEN;
    public static final String SAP_CREATE_PROJECT_ENDPOINT = System.label.SAP_CREATE_PROJECT_ENDPOINT;

    public static final String SAP_CREATE_PIR_REQ_ENDPOINT = System.label.SAP_CREATE_PIR_REQ_ENDPOINT;
    public static final String SAP_CREATE_PIR_ENDPOINT = System.label.SAP_CREATE_PIR_ENDPOINT;

    public static final String SAP_CUSTOMER_AUTH_HEADER = System.label.SAP_CUSTOMER_AUTH_HEADER;
    public static final String SAP_CUSTOMER_UPDATE_AUTH = System.label.SAP_CUSTOMER_UPDATE_AUTH;
    public static final String SAP_PROJECT_AUTH_HEADER = System.label.SAP_PROJECT_AUTH_HEADER;
    public static final String SAP_PIR_AUTH_HEADER = System.label.SAP_PIR_AUTH_HEADER;
    public static final String SAP_FERT_AUTH_HEADER = System.label.SAP_FERT_AUTH_HEADER;

    public static final String PROJECT_SUBMITTION_STATUS = System.label.PROJECT_SUBMITTION_STATUS;
    public static final String APPLICATION_SUBMITTION_STATUS = System.label.APPLICATION_SUBMITTION_STATUS;
    public static final String SAMPLING_SUBMITTION_STATUS = System.label.SAMPLING_SUBMITTION_STATUS;

    //v1.1 Product visibility add-on's, wherever we use the following var's make sure todo case in-sensitive search.
    public static final String PRODUCT_VISIBILITY_PUBLIC = 'public';
    public static final String PRODUCT_VISIBILITY_PRIVATE = 'private';
    public static final String PRODUCT_USEDBY_PORTFOLIO_PRODUCT = 'portfolio product';
    public static final String PRODUCT_USEDBY_TAILOR_MADE = 'tailor made';
    public static final String PRODUCT_USEDBY_FOOD_SERVICE = 'food service';
    public static final String PRODUCT_USEDBY_RESTRICTED = 'restricted';
    public static final String PRODUCT_SOLDBY_DIRECT = 'direct';
    public static final String PRODUCT_SOLDBY_CS = 'channel';
    public static final String PRODUCT_SOLDBY_FS = 'food service';

    public static final Set<String> SALES_GROUP_NAME_SET = new Set<String> {System.Label.GROUP_NAME_DIRECT, System.Label.GROUP_NAME_CHANNEL_SALES, System.Label.GROUP_NAME_FOOD_SERVICE};


    //REPEAT ORDER constants

    public static final String PRODUCT_QTY_OF_MESSAGE = 'Due to quantity overflow while repeat order creation, this product was split into new Opportunity.';
    public static final String PRODUCT_MOVED_MESSAGE = ' Has been moved to new opportunity due to order received was of less quantity.';
    public static final String PRODUCT_QTY_ALTERED_MESSAGE = 'This product quantity was altered due to repeat order. Original quantity was :';

    
}