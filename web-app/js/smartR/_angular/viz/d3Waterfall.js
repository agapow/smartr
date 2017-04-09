//# sourceURL=d3Waterfall.js

'use strict';

window.smartRApp.directive('pca', [
    'smartRUtils',
    'rServeService',
    '$rootScope',
    function(smartRUtils, rServeService, $rootScope) {

    return {
        restrict: 'E',
        scope: {
            data: '='
        },
        templateUrl: $rootScope.smartRPath +  '/js/smartR/_angular/templates/pca.html',
        link: function (scope, element) {
            var vizDiv = element.children()[0];
            /**
             * Watch data model (which is only changed by ajax calls when we want to (re)draw everything)
             */
            scope.$watch('data', function () {
                $(vizDiv).empty();
                if (! $.isEmptyObject(scope.data)) {
                    createWaterfallPlot(scope, vizDiv);
                }
            });
        }
    };

    function createWaterfallPlot(scope, vizDiv) {
        // SOME TESTING HACK - DO NOT INCLUDE IN RELASE
        var debugField = d3.select(root).append('div');
        debugField.text ("THEIS IS TEST TEXT");

        var debugDataField = d3.select(root).append('div');
        var debugDataStr = JSON.stringify (scope.data, null, 2);
        debugDataField.text (debugDataStr);

        var cf = crossfilter(scope.data.dataMatrix);
        var byValue = cf.dimension(function(d) { return d.value; });
        var byBioMarker = cf.dimension(function(d) { return d.bioMarker; });

        var plotData = [];
        smartRUtils.unique(smartRUtils.getValuesForDimension(byBioMarker)).forEach(function(bioMarker) {
            byBioMarker.filterExact(bioMarker);
                plotData.push({
                    type: 'box',
                    y: smartRUtils.getValuesForDimension(byValue),
                    name: bioMarker,
                    boxpoints: 'all',
                    boxmean: 'sd',
                    jitter: 0.5
                });
            byBioMarker.filterAll();
        });

        var title = 'Boxplots (' + scope.data.transformation + ')';
        title += scope.data.pValue ? ' ANOVA pValue = ' + scope.data.pValue : '';
        var layout = {
            title: title,
            height: 800
        };
        Plotly.newPlot(vizDiv, plotData, layout);

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

            // Main:
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

