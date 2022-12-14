package
{
   import mx.resources.ResourceBundle;
   
   public dynamic class en_US$rpc_properties extends ResourceBundle
   {
       
      
      public function en_US$rpc_properties()
      {
         super("en_US","rpc");
      }
      
      override protected function getContent() : Object
      {
         return {
            "cannotResetOperationName":"Cannot reset the name of an Operation",
            "cannotResetService":"Cannot reset the service of an Operation",
            "operationsNotAllowedInService":"Cannot assign operations into an RPC Service ({0})",
            "invalidResultFormat":"Invalid resultFormat \'{0}\' valid formats are [{1}, {2}, {3}, {4}, {5}]",
            "xmlEncodeReturnNull":"xmlEncode returned null",
            "xmlEncodeReturnNoXMLNode":"xmlEncode did not return XMLNode",
            "urlNotSpecified":"A URL must be specified with useProxy set to false.",
            "xmlDecodeReturnNull":"xmlDecode returned null",
            "defaultDecoderFailed":"Default decoder could not decode result",
            "unknownProtocol":"Unknown protocol \'{0}",
            "pendingCallExists":"Attempt to invoke while another call is pending.  Either change concurrency options or avoid multiple calls.",
            "noListenerForEvent":"An event was received for which no listener was defined. Please add an event listener. {0}",
            "soapVersionMismatch":"Request implements version: {0}, Response implements version {1}",
            "missingInputParameter":"Array of input arguments did not contain a required parameter at position {0}",
            "missingInputParameterWithName":"Required parameter \'{0}\' not found in input arguments.",
            "tooFewInputParameters":"Too few parameters - expected at least {0} but found {1}",
            "unexpectedInputParameter":"Unexpected parameter \'{0}\' found in input arguments.",
            "wsdlDefinitionsNotFirst":"Definitions must be the first element in a WSDL document",
            "noBaseWSDLAddress":"Cannot resolve relative WSDL import without a fully qualified base address.",
            "noBaseWSDLAddress.details":"Please specify the location of the WSDL document for the WebService.",
            "noServiceElement":"Could not load WSDL",
            "noServiceElement.details":"No <wsdl:service> elements found in WSDL at {0}.",
            "unrecognizedNamespace":"The WSDL parser had no registered document for the namespace \'{0}",
            "unrecognizedPortTypeName":"The WSDL parser couldn\'t find a portType named \'{0}\' in namespace \'{1}",
            "overloadedOperation":"The WSDL contains an overloaded operation ({0}) - we do not currently support this usage.",
            "unrecognizedMessageName":"The WSDL parser couldn\'t find a message named \'{0}\' in namespace \'{1}",
            "badElement":"Element {0}:{1} not resolvable",
            "badType":"Type {0} not resolvable",
            "unexpectedException":"Runtime exception {0}",
            "unableToLoadWSDL":"Unable to load WSDL. If currently online, please verify the URI and/or format of the WSDL ({0})",
            "faultyWSDLFormat":"Faulty WSDL format",
            "unrecognizedBindingName":"The WSDL parser couldn\'t find a binding named \'{0}\' in namespace \'{1}",
            "unknownSchemaType":"Unknown schema type system",
            "unknownSchemaVersion":"Unknown schema version",
            "badSchemaNode":"Bad schema node",
            "noBaseSchemaAddress":"Cannot resolve relative schema import without a fully qualified base address.",
            "unexpectedSchemaException":"Error while importing schema: {0}",
            "errorWhileLoadingFromParent":"Error while loading imported schema from parent location: {0}",
            "unknownSchemaElement":"Unknown element: {0}",
            "cannotFindType":"Cannot find type for: {0}",
            "cannotConnectToDestination":"Couldn\'t establish a connection to \'{0}",
            "invalidSoapResultFormat":"Invalid resultFormat \'{0}\'. Valid formats are \'object\', \'xml\', and \'e4x",
            "noListenerForHeader":"No event listener for header {0}",
            "mustSpecifyWSDLLocation":"You must specify the WSDL location with useProxy set to false.",
            "destinationOrWSDLNotSpecified":"A destination and/or WSDL must be specified.",
            "noSuchServiceInWSDL":"The requested service \'{0}\' was not found in the WSDL file.",
            "noServices":"There are no valid services in the WSDL file.",
            "noSuchService":"Couldn\'t find service \'{0}",
            "noPortsInWSDL":"There are no valid ports in the WSDL file for the {0} service.",
            "multiplePortsFound":"A valid port was not specified. Unable to select a default port as there are multiple ports in the WSDL file.",
            "noServiceAndPort":"Couldn\'t find a matching port (service = \'{0}\', port = \'{1}\')"
         };
      }
   }
}
