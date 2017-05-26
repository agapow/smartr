//# sourceURL=d3Marker.js

'use strict';

window.smartRApp.directive('markerPlot', [
    'smartRUtils',
    'rServeService',
    '$rootScope',
    function(smartRUtils, rServeService, $rootScope) {

    return {
        restrict: 'E',
        scope: {
            data: '='
        },
        templateUrl: $rootScope.smartRPath +  '/js/smartR/_angular/templates/qq.html',
        link: function (scope, element) {
            var vizDiv = element.children()[0];
            /**
             * Watch data model (which is only changed by ajax calls when we want to (re)draw everything)
             */
            scope.$watch('data', function () {
                $(vizDiv).empty();
                if (! $.isEmptyObject(scope.data)) {
                    createMarkerPlot(scope, vizDiv);
                }
            });
        }
    };


    function createQqPlot(scope, root) {
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

