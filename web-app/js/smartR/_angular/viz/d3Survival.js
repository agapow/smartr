//# sourceURL=d3Survival.js

'use strict';

window.smartRApp.directive('survivalPlot', [
    'smartRUtils',
    'rServeService',
    '$rootScope',
    function(smartRUtils, rServeService, $rootScope) {

    return {
        restrict: 'E',
        scope: {
            data: '='
        },
        templateUrl: $rootScope.smartRPath +  '/js/smartR/_angular/templates/survival.html',
        link: function (scope, element) {
            var vizDiv = element.children()[0];
            /**
             * Watch data model (which is only changed by ajax calls when we want to (re)draw everything)
             */
            scope.$watch('data', function () {
                $(vizDiv).empty();
                if (! $.isEmptyObject(scope.data)) {
                    createSurvivalPlot(scope, vizDiv);
                }
            });
        }
    };


    function createSurvivalPlot(scope, root) {
        // SOME TESTING HACK - DO NOT INCLUDE IN RELASE
        var debugField = d3.select(root).append('div');
        debugField.text ("in createQqPlot in d3Qq");

        var debugDataField = d3.select(root).append('div');
        var debugDataStr = JSON.stringify (scope.data, null, 2);
        debugDataField.text (debugDataStr);

        var output_elem = appendOutput (root, "QQ plot");
        appendParams (output_elem, scope.data.params);




    }

}]);

