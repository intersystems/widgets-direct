angular
  .module('WidgetsDirect')
   .controller('WidgetController', ['$q', '$scope', '$timeout', '$http', '$log', '$mdDialog',function($q, $scope, $timeout, $http, $log, $mdDialog) {
	
	  $scope.editWidget = function(ev, widget) {
         var parent = angular.element(document.body);
         $scope.newwidget = widget;
         	
         $mdDialog.show({
            parent: parent,
            clickOutsideToClose: true,
            scope: $scope,
            preserveScope: true,
            targetEvent: ev,
            templateUrl: '/widgetsdirect/modules/widget/EditWidget.csp',
            controller: function DialogController($scope, $mdDialog, $http, $log) {

                $scope.saveWidget = function(widget) {
                  $http.put('/widgetsdirect/rest/'+widget.Id, widget).then(
                     function(data) {
                       
                        $mdDialog.hide();
                    
                     },
                     function(data) {
                       
                          $log.info('Update failed ');

                     }
                  );
               };
            }
         })
      };
	
	
	   
   		}
   	  ]
   )