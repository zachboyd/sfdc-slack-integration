public with sharing class SlackWebApi {
	
    public class SlackMessage {
    	
        @InvocableVariable( label = 'Channel' required = true )
        public String channel;
        
        @InvocableVariable( label = 'Message' required = true )
        public String text;
        
        @InvocableVariable( label = 'As user' required = false description = 'Should this post as the currently logged in user' )
        public Boolean as_user = true;   
        
        @InvocableVariable( label = 'Bot Name' description = 'Name of bot that this message should post as. Post As User must be false.' required = false )
        public String username;
        
    }
    
    @InvocableMethod( label = 'Post Message to Slack' )
    public static void postMessage( List<SlackMessage> messageList ) {
        
        if( messageList != null ) {
            
            for( SlackMessage message : messageList ) {           
                
                // convert html to text. this approach could support slack compliant markdown
                // in the future.
                message.text = convertHtmlToText( message.text );
                
                QueueableSlackCall call = new QueueableSlackCall( 
                    'callout:Slack/chat.postMessage', 
                    'POST', 
                    createPostBody( message )
                );
                
                System.enqueueJob( call );
                
            } 
            
        }        
    }
    
    private static String convertHtmlToText( String html ) {
        
        DOM.Document doc = new DOM.Document();
        
        try {
            doc.load( html );   
            return walkThrough( doc.getRootElement() );            
        }
        catch( System.XmlException xe ) {            
            return xe.getMessage();            
        }
        
    }
    
    private static String walkThrough( DOM.XMLNode node ) {
        
        String result = '';
        
        if (node.getNodeType() == DOM.XMLNodeType.TEXT) {
            return node.getText();
        }
        
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            
            // TODO if tags should be converted to mark down then 
            // do that within this block
            
            if( node.getText().trim() != '' ) {                            
                result += node.getText();
            }
            
            for( Dom.XMLNode child: node.getChildElements() ) {
                result += walkThrough( child );
            }
            
            return result;
            
        }
        
        return '';  //should never reach here 
        
    }
        
    private static String createPostBody( Object obj ) {
        
        // go ahead and add token to body. this uses merge parameters so the named credentials
        // must support merge parameters on the http body
        String body = 'token={!$Credential.OAuthToken}';
        
        // Convert object to map so we can iterate properties and append to body
    	Map<String,Object> objMap = (Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( obj ) );
        
        if( objMap != null ) {
            
            for( String key : objMap.keySet() ) { 
                
                Object val = objMap.get( key );
                
                if( val instanceof String ) {
                    val = EncodingUtil.urlEncode( (String) val, 'UTF-8' );
                }
                
                body += '&' + key + '=' + val;
                
            }
            
        }
        
        System.debug( body );
        
        return body;
        
    }
    
    /**
    * Class taken from http://coenraets.org/blog/2016/01/slack-salesforce-integration/
    */
    public class QueueableSlackCall implements System.Queueable, Database.AllowsCallouts {
         
        private final String url;
        private final String method;
        private final String body;
         
        public QueueableSlackCall( String url, String method, String body ) {
            this.url = url;
            this.method = method;
            this.body = body;
        }
         
        public void execute( System.QueueableContext ctx ) {
            
            HttpRequest req = new HttpRequest();
            
            req.setEndpoint( url );
            req.setMethod( method );
            req.setBody( body );
            
            Http http = new Http();
            
            HttpResponse res = http.send( req );
            
        }
 
    }
    
}
