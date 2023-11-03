public without sharing class VolumeBasedDiscountCalculation {
    
    static VolumeBasedDiscountCalculation volumeBasedObj;
    Map<Id,Decimal> customerDiscountMap;
    Map<String,Volume_Based_Discount__mdt> vbdMap;
    Map<String,List<Volume_Based_Discount__mdt>> mapOfVbList = new Map<String,List<Volume_Based_Discount__mdt>>();


    public static VolumeBasedDiscountCalculation getInstance(){
        if(volumeBasedObj==null){
            volumeBasedObj = new VolumeBasedDiscountCalculation();
        }
        return volumeBasedObj;
    }

    public List<OpportunityLineItem> calculateVolumeBasedDiscount(List<OpportunityLineItem> lineItems, boolean isUpdate){
        List<Volume_Based_Discount__mdt> vbList = Volume_Based_Discount__mdt.getAll().values();
        
        for(Volume_Based_Discount__mdt vdt : vbList){
            if(mapOfVbList.containsKey(vdt.Label)){
                mapOfVbList.get(vdt.Label).add(vdt);
            }else{
                mapOfVbList.put(vdt.Label,new List<Volume_Based_Discount__mdt>{vdt});
            }
        }

        System.debug('mapOfVbList'+mapOfVbList);

        vbdMap = Volume_Based_Discount__mdt.getAll();
        customerDiscountMap = getCustomerDiscountMap(lineItems,isUpdate);
        
        return getDiscountBasedOnFamily(lineItems);
    }

    public  Map<Id,Decimal> getCustomerDiscountMap(List<OpportunityLineItem> lineItems, boolean isUpdate){

        Set<Id> oppIdSet = new Set<Id>();
        Map<Id,Decimal> customerDiscountMap = new Map<Id,Decimal>();
        
        for(OpportunityLineItem lineItem : lineItems){
            oppIdSet.add(lineItem.OpportunityId);
        }

        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select Id,AccountId,Account.Customer_Discount__c From Opportunity Where Id In : oppIdSet AND Account.Customer_Discount__c > 0]);

        for(OpportunityLineItem lineItem : lineItems){
            if(oppMap.containsKey(lineItem.OpportunityId)){
                Opportunity opp = oppMap.get(lineItem.OpportunityId);
                customerDiscountMap.put(lineItem.OpportunityId,opp.Account.Customer_Discount__c);
            }
        }

        return isUpdate?new Map<Id,Decimal>():customerDiscountMap;
    }

    public  List<OpportunityLineItem> getDiscountBasedOnFamily(List<OpportunityLineItem> lineItems){
        Set<Id> setOfProductId = new Set<Id>();

        for(OpportunityLineItem lineItem : lineItems){
            setOfProductId.add(lineItem.Product2Id);
        }

        Map<Id,Product2> prodMap = new Map<Id,Product2>([Select Id, Family From Product2 Where Id IN : setOfProductId AND Family!=null ]);

        for(OpportunityLineItem lineItem : lineItems){
            Decimal actualPrice = lineItem.UnitPrice;
            lineItem.Discount_Description__c = '';
            Decimal customerDiscount = 0;

            if(customerDiscountMap.containsKey(lineItem.OpportunityId)){
                customerDiscount = customerDiscountMap.get(lineItem.OpportunityId); 
            }

            if(lineItem.UnitPrice!=null && lineItem.UnitPrice>0 && prodMap.containsKey(lineItem.Product2Id)){
                String prodFamily = prodMap.get(lineItem.Product2Id).Family;
                if(lineItem.Customer_Discount_Applied__c == false && customerDiscount != null && customerDiscount>0){
                    actualPrice -= (actualPrice*customerDiscount)/100; 
                    lineItem.Discount_Description__c += 'Added Customer discount by : '+customerDiscount+' %';
                    lineItem.Customer_Discount_Applied__c = true;
                }

                if(!String.isEmpty(prodFamily) && mapOfVbList.containsKey(prodFamily)){

                    Decimal amount = actualPrice;
                    System.debug('--- amount'+ amount);
                    for(Volume_Based_Discount__mdt vbd : mapOfVbList.get(prodFamily)){

                        if(lineItem.Volume_Based_Amount__c!=null && !String.isEmpty(lineItem.Volume_Based_Unit__c)){

                            //amount -= lineItem.Volume_Based_Amount__c;

                            if(lineItem.Volume_Based_Unit__c != lineItem.Quantity_Unit__c) {
                                if(lineItem.Volume_Based_Unit__c == 'Kg' || lineItem.Volume_Based_Unit__c == 'Liter') {
                                    amount = measurementConversionUnit(amount,lineItem.Quantity_Unit__c,lineItem.Volume_Based_Unit__c);
                                }else if(lineItem.Volume_Based_Unit__c == 'Gm' || lineItem.Volume_Based_Unit__c == 'mL') {
                                    amount = measurementConversionUnit(amount,lineItem.Quantity_Unit__c,lineItem.Volume_Based_Unit__c);
                                }else if(lineItem.Volume_Based_Unit__c == 'Tonne') {
                                    amount = measurementConversionUnit(amount,lineItem.Quantity_Unit__c,lineItem.Volume_Based_Unit__c);
                                }else {
                                    System.debug(' --- couldnt get matching unit');
                                    continue;
                                }

                                System.debug('After Breaking in prev unit---'+amount);
                                amount -= lineItem.Volume_Based_Amount__c;
                            }else {
                                amount -= lineItem.Volume_Based_Amount__c;
                            }

                            amount = measurementConversionUnit(amount,lineItem.Volume_Based_Unit__c,lineItem.Quantity_Unit__c);
                            lineItem.Volume_Based_Amount__c = null;
                            lineItem.Volume_Based_Unit__c = null;
                            lineItem.Discount_Description__c = '';
                            lineItem.Applied_Volume_Based_Markup__c = null;

                            System.debug('--- after deducting old markup amount'+ amount);
                        }

                        Decimal quantityInKg = getQuantityInKg(lineItem.Quantity,lineItem.Quantity_Unit__c);

                        if(quantityInKg < vbd.Markup_Quantity_Kg__c && quantityInKg > vbd.Markup_Quantity_G_KG__c){
                            //amount = getKGPrice(amount,lineItem.Quantity_Unit__c);
                            System.debug('--- after converting ampount to KG '+ amount);
                            Decimal markedUpAmount = (amount*vbd.Markup_Price__c)/100; 
                            System.debug('--- markedUpAmount '+ markedUpAmount);
                            System.debug('--- before markup amount - '+ amount);
                            amount = amount + markedUpAmount;
                            System.debug('--- after markup amount - '+ amount);
                            //lineItem.UnitPrice = getUPriceKgToSelectedUnit(amount,lineItem.Quantity_Unit__c);
                            lineItem.UnitPrice = amount;
                            if(lineItem.Discount_Description__c.length()>0){
                                lineItem.Discount_Description__c+=' , ';
                            }
                            lineItem.Discount_Description__c += ' Added Voume based markup by : '+vbd.Markup_Price__c+' % because quantity falls under > '+vbd.Markup_Quantity_G_KG__c+' and < '+vbd.Markup_Quantity_Kg__c;
                            lineItem.Applied_Volume_Based_Markup__c = vbd.Markup_Price__c;
                            lineItem.Volume_Based_Unit__c = lineItem.Quantity_Unit__c;
                            lineItem.Volume_Based_Amount__c = markedUpAmount;
                            break;
                        }else{
                            //lineItem.UnitPrice = amount;
                        }
                    }
                }
            }
        }

        return lineItems;
    }


    public Decimal measurementConversionUnit(Decimal cPrice, String sourceUnit,String convertIntoUnit){
        
        //sourceUnit = Quantity_Unit__c // kg
        //convertIntoUnit = VB_Unit // gm

        if(sourceUnit=='Kg' || sourceUnit == 'Liter'){
            switch on convertIntoUnit {
                when 'Gm','mL'{
                    return cPrice / 1000;
                }
                when 'Tonne'{
                    return cPrice * 1000;
                }
                when else {
                    return  cPrice;
                }
            }
        }else if(sourceUnit=='Gm' || sourceUnit == 'mL'){
            switch on convertIntoUnit {
                when 'Kg','Liter'{
                    return cPrice * 1000;
                }
                when 'Tonne'{
                    return cPrice * 1000000;
                }
                when else {
                    return  cPrice;
                }
            }
        }else if(sourceUnit=='Tonne'){
            switch on convertIntoUnit {
                when 'Kg','Liter'{
                    return cPrice / 1000;
                }
                when 'Gm','mL' {
                    return cPrice / 1000000;
                }
                when else {
                    return  cPrice;
                }
            }
        }else{
            return  cPrice;
        }
    }



    public Decimal getKGPrice(Decimal price, String unit){
        if(unit=='Kg' || unit=='Liter'){
            return price;
        }else if(unit=='Gm' || unit=='mL'){
            return price * 1000;
        }else{
            return price * 1000000;
        }
    }

    public Decimal getUPriceKgToSelectedUnit(Decimal kgPrice,String unit){
        if(unit=='Kg' || unit=='Liter'){
            return kgPrice;
        }else if(unit=='Gm' || unit=='mL'){
            return kgPrice / 1000;
        }else{
            return kgPrice / 1000000; //Tonne
        }
    }

    public Decimal getQuantityInKg(Decimal quantity, String unit){
        if(unit=='Kg' || unit=='Liter'){
            return quantity;
        }else if(unit=='Gm' || unit=='mL'){
            return quantity / 1000;
        }else{
            return quantity * 1000;
        }
    }


    public Decimal unitConversionHelperPerKG(Decimal perKgPrice, String conversionToUnit) {
        if(perKgPrice == null || perKgprice <= 0 || conversionToUnit == null)
            return perKgPrice;
        else {

            switch on conversionToUnit {
                when 'Gm','mL' {
                    return perKgPrice / 1000;
                }
                when 'Liter' {
                    return perKgPrice; //Since same
                }
                when 'Tonne' {
                    return perKgPrice * 1000;
                }
                when else {
                    return perKgPrice;
                }
            }
            
        }
    }

    public Decimal unitConversionHelperPerGM(Decimal perGMPrice, String conversionToUnit) {
        if(perGMPrice == null || perGMPrice <= 0 || conversionToUnit == null)
            return perGMPrice;
        else {

            switch on conversionToUnit {
                when 'Kg','Liter' {
                    return perGMPrice * 1000; //Since same
                }
                when 'Tonne' {
                    return perGMPrice * 1000 * 1000;
                }
                when else {
                    return perGMPrice;
                }
            }
            
        }
    }
}