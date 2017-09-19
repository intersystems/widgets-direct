var app = angular.module('WidgetsDirect', ['ngMaterial','ui.router']);
	
	app.config(function($stateProvider, $urlRouterProvider) {
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
	        });
	    $urlRouterProvider.otherwise('/login');
    });
    app.controller("LoginController", function($scope) {
	
	    $scope.login = function() {
	        window.location.href = "https://login.intersystems.com/uat/oauth2/authorize?client_id=" + "xI9KckkpNES-qW0Rr1fTYmRQPvVu5BAwfAAIpdKyHCs" + "&response_type=token"
	    }
	
	});
	app.controller("SecureController", function($scope) {
	
	    $scope.accessToken = JSON.parse(window.localStorage.getItem("sso")).oauth.access_token;
	
	});

