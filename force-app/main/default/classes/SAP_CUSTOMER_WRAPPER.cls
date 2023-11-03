public class SAP_CUSTOMER_WRAPPER{
	public String SF_ID;	//0019D00000Lixm4QAB
	public String CUSTOMER_NAME;	//Akhil K G
	public String CUSTOMER_NAME_2;	//Akhil K G
	public String STREET_2;	//NO:80,BOMMASANDRA INDUSTRIAL AREA
	public String STREET_3;	//EAKKATUHANGAL, MAIN ROAD,
	public String STREET;	//SOFTWARE AREA, TAMILNAIDU
	public String POSTAL_CODE;	//600037
	public String CITY;	//CHENNAI
	public String COUNTRY;	//IN
	public String STATE;	//TN
	public String SALES_EMP;	//Gisha Vijayan
	public String CUSTOMER_CATEGORY;	//DIRECT
	public cls_CUSTOMER_CONTACT_INFOS[] CUSTOMER_CONTACT_INFO;
	public String BUSINESS_HEAD_NAME;	//Velumuttu Bhaskar
	public String TAX_TYPE;	//Unspec. person responsible for sales/purch.tax
	public String GSTIN_NUMBER;	//29GGGGG1314R9Z6
	public String PAN_NUMBER;	//ALWPG5809L
	public String CUSTOMER_GROUP;	//Regular
	public String XCURRENCY;	//INR
	public String DELIVERY_PLANT;	//FLAVOURS - 1201
	public String DOMESTIC_EXPORT;	//DOMESTIC
	public String PAYMENT_TERMS;	//Due after 40 days
	public String TCS;	//No
	public String ACC_OWNER_EMAIL;	//jess@symega.com
	public String FSSAI_NUMBER;	//64758676849393
	public String TRANSPORTATION_TERMS;	//Carriage and insurance paid to
	
    public class cls_CUSTOMER_CONTACT_INFOS {
		public String name;	//nithin
		public String phone;	//9249500002
		public String email;	//nithin@gmail.com
	}
	public static SAP_CUSTOMER_WRAPPER parse(String json){
		return (SAP_CUSTOMER_WRAPPER) System.JSON.deserialize(json, SAP_CUSTOMER_WRAPPER.class);
	}
}