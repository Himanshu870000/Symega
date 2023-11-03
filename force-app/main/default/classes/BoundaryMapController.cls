global without sharing class BoundaryMapController {

    @RemoteAction
    global static Map<String, List<Object>> getBoundaryMap() {
        String currentUserId = UserInfo.getUserId();

        List<Route__c> routes = [SELECT Id, Name, Route_Name_del__c
                                 FROM Route__c
                                 WHERE Sales_User__c = :currentUserId];

        Map<String, List<Object>> routeToAccounts = new Map<String, List<Object>>();

        List<Account> accounts = [SELECT Id, Name, BillingStreet, Geo_Location__latitude__s, Geo_Location__longitude__s
                                  FROM Account
                                  WHERE BillingStreet LIKE :getRouteNameFilters(routes)];

        for (Route__c route : routes) {
            routeToAccounts.put(route.Route_Name_del__c, new List<Object>());
        }

        for (Account acc : accounts) {
            for (Route__c route : routes) {
                if (acc.BillingStreet != null && acc.BillingStreet.contains(route.Route_Name_del__c)) {
                    routeToAccounts.get(route.Route_Name_del__c).add(acc);
                }
            }
        }

        System.debug('routeToAccounts------->' + routeToAccounts);

        return routeToAccounts;
    }

    private static Set<String> getRouteNameFilters(List<Route__c> routes) {
        Set<String> filters = new Set<String>();
        for (Route__c route : routes) {
            filters.add('%' + route.Route_Name_del__c + '%');
        }
        return filters;
    }
}