
<script type="text/ng-template" id="marker">

<div ng-controller="MarkerController">

    <tab-container>

        <workflow-tab tab-name="Fetch Data" disabled="fetch.disabled">
            <concept-box style="display: inline-block"
                         concept-group="fetch.conceptBoxes.datapoints"
                         type="HD"
                         min="1"
                         max="1"
                         label="Numerical Variables"
                         tooltip="Select high dimensional data to compare across cohorts.">
            </concept-box>
            <br/>
            <br/>

            <hr class="sr-divider">
            <fetch-button concept-map="fetch.conceptBoxes"
                          loaded="fetch.loaded"
                          running="fetch.running"
                          disabled="fetch.button.disabled"
                          message="fetch.button.message"
                          allowed-cohorts="[2]">
            </fetch-button>

        </workflow-tab>

        <workflow-tab tab-name="Run Analysis" disabled="runAnalysis.disabled">
           <div class="heim-input-field sr-input-area">
               <div class="heim-input-field">
                   <input type="checkbox" ng-model="runAnalysis.params.includeTable">
                   <span>Include table of data</span>
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
            <marker-plot data="runAnalysis.scriptResults"></marker-plot>
        </workflow-tab>

    </tab-container>

</div>

</script>
