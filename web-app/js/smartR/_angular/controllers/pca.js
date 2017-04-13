//# sourceURL=pca.js

'use strict';

window.smartRApp.controller('PcaController', [
    '$scope',
    'smartRUtils',
    'commonWorkflowService',
    function($scope, smartRUtils, commonWorkflowService) {

        commonWorkflowService.initializeWorkflow('pca', $scope);

        $scope.fetch = {
            disabled: false,
            running: false,
            loaded: false,
            selectedBiomarkers: [],
            conceptBoxes: {
                highDimensional: {concepts: [], valid: false}
            },
            button: {
                disabled: true,
                message: ''
            },
        };

        $scope.runAnalysis = {
            params: {
                dropMissingSubjects: false,
                calcZScore: false,
                aggregateProbes: false
            },
            disabled: true,
            running: false,
            scriptResults: {}
        };

        $scope.$watch(
            function() {
                //return $scope.fetch.conceptBoxes.highDimensional.concepts.length;
                return $scope.fetch.conceptBoxes.highDimensional.concepts.length + ' ' + $scope.fetch.selectedBiomarkers.length;
            },
            function() {
                if ($scope.fetch.conceptBoxes.highDimensional.concepts.length === 0) {
                    $scope.fetch.button.disabled = true;
                    $scope.fetch.button.message = 'Please select a high dimensional concept';
                } else if ($scope.fetch.selectedBiomarkers.length === 0 || $scope.fetch.selectedBiomarkers.length > 10) {
                    $scope.fetch.button.disabled = true;
                    $scope.fetch.button.message = 'Please select between 1 and 10 biomarkers for your high dimensional data';
                } else {
                    $scope.fetch.button.disabled = false;
                    $scope.fetch.button.message = '';
                }
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

