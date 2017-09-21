	//Set these variables to the authorize endpoint and your clientId.
	//e.g. "https://server.example.com/oauth/authorize"
	var authorizeURL = "";
	var clientId = "";
	
angular.module('WidgetsDirect')
	.config(function($stateProvider, $urlRouterProvider) {
	    $stateProvider
	        .state('login', {
	            url: '/login',
	            templateUrl: 'Modules/OAuth/Login.csp',
	            controller: 'LoginController'
	        })
	        .state('secure', {
	            url: '/secure',
	            templateUrl: 'Modules/OAuth/Secure.csp',
	            controller: 'SecureController'
	        })
	        .state('default', {
	            url: '/default',
	            templateUrl: 'Modules/OAuth/Default.csp',
	            controller: "DefaultController"
	        });
	    $urlRouterProvider.otherwise('/default');
    })
    .controller("LoginController", function($scope) {
	
	    $scope.login = function() {
	    	 window.location.href = authorizeURL+"?client_id=" + clientId + "&response_type=token&state=STATE"
	    }
	
	})
	.controller("SecureController", function($scope) {
	
	    $scope.accessToken = JSON.parse(window.localStorage.getItem("oauth")).access_token;
	    $scope.hide = function() {
	    	window.location.hash = "/default";
	    }
	    
	})
	.controller("DefaultController", function($scope) {
	
	    $scope.show = function() {
	    	if (window.localStorage.getItem("sso") != null)
	    		window.location.hash = "/secure";
	    	else 
	    		window.location.hash = "/login";
	    }
	    
	});