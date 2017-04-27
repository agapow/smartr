//# sourceURL=pca.js

'use strict';

window.smartRApp.controller('QqController', [
    '$scope',
    'smartRUtils',
    'commonWorkflowService',
    function($scope, smartRUtils, commonWorkflowService) {

        commonWorkflowService.initializeWorkflow('qq', $scope);

        $scope.fetch = {
            disabled: false,
            running: false,
            loaded: false,
            conceptBoxes: {
                datapoints: {concepts: [], valid: false}
            },
            button: {
                disabled: true,
                message: ''
            },
        };

        $scope.runAnalysis = {
            params: {
                includeTable: false
            },
            disabled: true,
            running: false,
            scriptResults: {}
        };

        $scope.$watch(
            function() {
                //return $scope.fetch.conceptBoxes.highDimensional.concepts.length;
                return $scope.fetch.conceptBoxes.datapoints.concepts.length;
            },
            function() {
                // nothing?
            }
        );

        $scope.$watchGroup(['fetch.running', 'runAnalysis.running'],
            function(newValues) {
                var fetchRunning = newValues[0],
                    runAnalysisRunning = newValues[1];

                // clear old results
                if (fetchRunning) {
                    $scope.runAnalysis.scriptResults = {};
                }

                // disable tabs when certain criteria are not met
                $scope.fetch.disabled = runAnalysisRunning;
                $scope.runAnalysis.disabled = fetchRunning || !$scope.fetch.loaded;
            }
        );

    }]);

