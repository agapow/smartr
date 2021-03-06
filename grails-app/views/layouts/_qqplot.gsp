
<script type="text/ng-template" id="qq">

<div ng-controller="QqController">

    <tab-container>

        <workflow-tab tab-name="Fetch Data" disabled="fetch.disabled">
            <concept-box style="display: inline-block;"
                         concept-group="fetch.conceptBoxes.highDimensional"
                         type="HD"
                         min="1"
                         max="1"
                         label="High Dimensional Variables"
                         tooltip="Select a high dimensional variable for PCA analysis.">
            </concept-box>
            <biomarker-selection biomarkers="fetch.selectedBiomarkers"></biomarker-selection>
            <br/>
            <br/>

            <hr class="sr-divider">
            <fetch-button concept-map="fetch.conceptBoxes"
                          loaded="fetch.loaded"
                          running="fetch.running"
                          biomarkers="fetch.selectedBiomarkers"
                          disabled="fetch.button.disabled"
                          message="fetch.button.message"
                          allowed-cohorts="[1]">
            </fetch-button>

        </workflow-tab>

        <workflow-tab tab-name="Run Analysis" disabled="runAnalysis.disabled">
           <div class="heim-input-field sr-input-area">
               <div class="heim-input-field">
                   <input type="checkbox" ng-model="runAnalysis.params.dropMissingSubjects">
                   <span>Drop subjects with missing data</span>
               </div>
               <div class="heim-input-field">
                   <input type="checkbox" ng-model="runAnalysis.params.calcZScore">
                   <span>Convert to Z scores z-score on the fly</span>
               </div>
               <div class="heim-input-field">
                   <input type="checkbox" ng-model="runAnalysis.params.aggregateProbes">
                   <span>Aggregate probes</span>
               </div>

           </div>
            <hr class="sr-divider">
            <run-button button-name="Create Plot"
                        store-results-in="runAnalysis.scriptResults"
                        script-to-run="run"
                        arguments-to-use="runAnalysis.params"
                        running="runAnalysis.running">
            </run-button>
            <br/>
            <br/>
            <pca-plot data="runAnalysis.scriptResults"></pca-plot>
        </workflow-tab>

    </tab-container>

</div>

</script>
