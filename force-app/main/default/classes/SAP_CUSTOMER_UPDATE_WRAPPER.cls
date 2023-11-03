public class SAP_CUSTOMER_UPDATE_WRAPPER {

    public String CUSTOMER_SAP_CODE;
    public String TRANSPORTATION_TERMS;
    public String STREET;
    public String STREET_2;
    public String STREET_3;
    public String SALES_EMP;
    public String POSTAL_CODE;
    public String PAYMENT_TERMS;
    public String PAN_NUMBER;
    public String GSTIN_NUMBER;
    public String FSSAI_NUMBER;
    public String DOMESTIC_EXPORT;
    public String CUSTOMER_NAME;
    public String CUSTOMER_GROUP;
    public String CUSTOMER_CATEGORY;
    public String COUNTRY;
    public String CITY;
    public String BUSINESS_HEAD_NAME;
    public String ACC_OWNER_EMAIL;
    public String DELIVERY_PLANT;
    
    //new 
    public String XCURRENCY;
    public String TCS;

    public List<CUSTOMER_CONTACT_WRAPPER> CUSTOMER_CONTACT_INFO;

    public class CUSTOMER_CONTACT_WRAPPER{
        public String name;
        public String phone;
        public String email;
    }
}