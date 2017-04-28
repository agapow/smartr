//# sourceURL=d3Pca.js

'use strict';



window.smartRApp.directive('pcaPlot', [
    'smartRUtils',
    'rServeService',
    '$rootScope',
    function(smartRUtils, rServeService, $rootScope) {

    return {
        restrict: 'E',
        scope: {
            data: '=',
            width: '@',
            height: '@'
        },
        templateUrl: $rootScope.smartRPath +  '/js/smartR/_angular/templates/pca.html',
        link: function (scope, element) {
            console.log("tataata")
            var vizDiv = element.children()[0];
            /**
             * Watch data model (which is only changed by ajax calls when we want to (re)draw everything)
             */
            scope.$watch('data', function () {
                $(vizDiv).empty();
                if (! $.isEmptyObject(scope.data)) {
                    createPcaPlot(scope, vizDiv);
                }
            });
        }
    };

    function createPcaPlot(scope, root) {
        console.log("in createPcaPlot in d3Pca")
        // SOME TESTING HACK - DO NOT INCLUDE IN RELASE
        var debugField = d3.select(root).append('div');
        debugField.text ("in createPcaPlot in d3Pca");

        var debugDataField = d3.select(root).append('div');
        var debugDataStr = JSON.stringify (scope.data, null, 2);
        debugDataField.text (debugDataStr);

        function drawTable (par_elem, table_data, table_class) {
            /*
             Render a table of data at given element.

             This assumes the data is structured thus::

             {
             header = ['foo', 'bar', 'baz'],
             rows = [
             [1, "two", 3.0],
             [4, "five", 6.0]
             ]
             }

            */
            // Preconditions & preparation:
            /* don't know what js engine we're using, so assume no default params */
            table_class = typeof table_class !== 'undefined' ? table_class : false;

            var table_elem = d3.select(par_elem).append('table');
            if (table_class) {
                table_elem.attr('class', table_class);
            }

            var thead = table.append('thead');
            var header = table_data.header;
            thead.append('tr')
                .selectAll('th')
                .data (header)
                .enter()
                .append('th')
                .text (function(d) { return d; }
            );

            var tbody = table.append('tbody');
            var rows = table_data.rows;
            rows.forEach (
                function (r) {
                    var currRow = tbody.append (tr);
                    r.forEach (
                        function (d) {
                            var currCell = tbody.append (td).text (d);
                        }
                    )
                }
            )

            return table_elem;
        }

    }
}]);

