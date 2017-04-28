//# sourceURL=d3Qq.js

'use strict';

window.smartRApp.directive('qqPlot', [
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
                    createQqPlot(scope, vizDiv);
                }
            });
        }
    };

    // SERIOUSLY, HOW DO WE SHARE FRIGGING FUNCTIONS???

    /*
     Set the default value for a variable if not defined.

     There is a facility for this in more recent javascript but we can't ensure
     that.
     */
    function defaultFor (arg, val) {
        return ((typeof arg === 'undefined') ? val : arg);
    }


    /*
     Capitalise the first letter of every word in string.
     */
    function capitalize (s) {
        return (s.replace(/\b./g, function(m){ return m.toUpperCase(); }));
    }


    /*
     Convert a camelCaps string into a space-delimited one.

     Note: copes with initial uppercase letter but not with numbers.
     */
    function camelToCaps (s) {
        s = s.replace (/([a-z])([A-Z])/g, "$1 $2");
        return (capitalize (s));
    }


    function appendTitle (root, title) {
        // Main:
        return (root.append('h1').text (title));
    }


    function appendSection (root, section_title) {
        // Main:
        return (root.append('h2').text (section_title));
    }


    function appendParams (root, params) {
        // Main:
        appendSection (root, "Parameters");

        var param_list = root.append ('ul');
        for (var key in params) {
            var item = param_list.append ('li').text (camelToCaps (key) + ': ' + params[key])
        }
    }


    function appendOutput (root, title) {
        // Preconditions:
        title = defaultFor (title, 'Analysis results');

        // Main:
        var output_elem = root.append ('div').attr ('id', 'analysisOutput');
        if (title) {
            appendTitle (output_elem, title);
        }

        // Return:
        return (output_elem);
    }

    /*
     Create a table as a child of the root element.

     Params:
     root: a d3 selected parent element
     data: a list of dicts, one for each row
     columns: column headers and the order of fields
     caption: (optional) title for the table

     */
    function appendTable (root, data, columns, caption) {
        // Main:
        // build basic table structure
        var table = root.append('table');
        table.attr ('class', 'sr-results-table');

        if (typeof caption !== 'undefined') {
            table.append ('caption').text (caption);
        }

        var thead = table.append ('thead');
        var tbody = table.append ('tbody');

        // append the header row
        var cappedCols = columns.map (function (c, i, a) {
                return camelToCaps (c);
            }
        );
        thead.append('tr')
            .selectAll ('th')
            .data (cappedCols).enter()
            .append ('th')
            .text (function (cappedCols) {
                    return cappedCols;
                }
            );

        // create a row for each object in the data
        var rows = tbody.selectAll('tr')
            .data (data).enter()
            .append ('tr');

        // create a cell in each row for each column
        var cells = rows.selectAll('td')
            .data (function (row) {
                return columns.map (function (column) {
                    return {column: column, value: row[column]};
                });
            })
            .enter()
            .append ('td')
            .text (function (d) { return d.value; });

        return (table);
    }

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
