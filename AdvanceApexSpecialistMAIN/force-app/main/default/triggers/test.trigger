trigger test on Account (before update) {
 /* List<Contact> ConList = [Select id, Lastname,FirstName from contact where AccountId IN : trigger.newMap.keyset()];
  List<Case> CaseList = [Select id, CaseNumber,Description from Case where AccountId IN : trigger.newMap.keyset()];
    for(Contact con : ConList){
        con.Lastname = con.Lastname + con.Firstname;
    }
    for(Case cs : CaseList){
        cs.AccountId = cs.Description + '0';
    }
    
    Update ConList ;
    Update CaseList ;*/
}