package de.wwu.md2.framework.generator.util.preprocessor

import de.wwu.md2.framework.mD2.AutoGeneratedContentElement
import de.wwu.md2.framework.mD2.ContainerElementRef
import de.wwu.md2.framework.mD2.MD2Factory
import de.wwu.md2.framework.mD2.MappingTask
import de.wwu.md2.framework.mD2.ValidatorBindingTask
import de.wwu.md2.framework.mD2.ViewElementRef
import de.wwu.md2.framework.mD2.ViewGUIElement
import java.util.Collection
import java.util.HashMap
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet

import static de.wwu.md2.framework.generator.util.MD2GeneratorUtil.*
import static de.wwu.md2.framework.generator.util.preprocessor.ProcessAutoGenerator.*
import static de.wwu.md2.framework.generator.util.preprocessor.ProcessController.*
import static de.wwu.md2.framework.generator.util.preprocessor.ProcessCustomEvents.*
import static de.wwu.md2.framework.generator.util.preprocessor.ProcessMappings.*
import static de.wwu.md2.framework.generator.util.preprocessor.ProcessModel.*
import static de.wwu.md2.framework.generator.util.preprocessor.ProcessView.*
import static de.wwu.md2.framework.generator.util.preprocessor.ProcessViewReferences.*
import static de.wwu.md2.framework.generator.util.preprocessor.ProcessWorkflow.*
import static de.wwu.md2.framework.generator.util.preprocessor.Util.*

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*

/**
 * Do a Model-to-Model transformation before the actual code generation process
 * to simplify the model.
 */
class PreprocessModel {
	
	def static ResourceSet preprocessModel(MD2Factory factory, ResourceSet input) {
		
		// Clone the model and perform all operations on the cloned model
		val workingInput = copyModel(input)
		
		
		
		/////////////////////////////////////////////////////////////////////////////
		//                                                                         //
		// Collections that are shared between tasks throughout the model          //
		// pre-processing workflow                                                 //
		//                                                                         //
		/////////////////////////////////////////////////////////////////////////////
		
		
		// Mapping of cloned (key) and original (value) elements
		// This is necessary to recalculate dependencies such as mappings,
		// event bindings and validator bindings after the cloning of references
		val HashMap<EObject, EObject> clonedElements = newHashMap()
		
		// populated by cleanUpUnnecessaryMappings(...):
		// Contains all mapping tasks that are set by the user
		val Collection<MappingTask> userMappingTasks = newHashSet()
		
		// populated by cleanUpUnnecessaryMappings(...):
		// Contains all mapping tasks that are created by the AutoGenerate element
		val Collection<MappingTask> autoMappingTasks = newHashSet()
		
		// populated by cleanUpUnnecessaryMappings(...):
		// Contains all mapping, that are separated into userMappingTasks and autoMappingTasks then
		val Collection<MappingTask> mappingTasks = workingInput.resources.map[ r |
				r.allContents.toIterable.filter(typeof(MappingTask)).filter([isCalledAtStartup(it)])
			].flatten.toList
		
		val Collection<ValidatorBindingTask> userValidatorBindingTasks = newHashSet()
		
		// all autogenerator elements
		val Iterable<AutoGeneratedContentElement> autoGenerators = workingInput.resources.map[ r |
			r.allContents.toIterable.filter(typeof(AutoGeneratedContentElement))
		].flatten
		
		// All references to container elements. After cloning the actual containers,
		// the references will be removed in a last step.
		val Iterable<ContainerElementRef> containerRefs = workingInput.resources.map[ r |
			r.allContents.toIterable.filter(typeof(ContainerElementRef))
		].flatten.toList
		
		// All references to view elements that have already been processed. After cloning the
		// actual view elements the references will be removed in a last step.
		val Collection<ViewElementRef> viewRefsDone = newHashSet()
		
		
		/////////////////////////////////////////////////////////////////////////////
		//                                                                         //
		// Preprocessing Workflow                                                  //
		//                                                                         //
		// HINT: The order of the tasks is relevant as tasks might depend on each  //
		//       other                                                             //
		//                                                                         //
		// TODO: Document (maybe enforce) pre-processing task dependencies         //
		//                                                                         //
		/////////////////////////////////////////////////////////////////////////////
		
		createStartUpActionAndRegisterAsOnInitializedEvent(factory, workingInput) // new
		
		transformEventBindingAndUnbindingTasksToOneToOneRelations(factory, workingInput) // new
		
		calculateParameterSignatureForAllSimpleActions(factory, workingInput) // new
		
		transformWorkflowsToSequenceOfCoreLanguageElements(factory, workingInput) // new
		
		transformAllCustomEventsToBasicLanguageStructures(factory, workingInput) // new
		
		transformImplicitEnums(factory, workingInput)
		
		setFlowLayoutPaneDefaultParameters(factory, workingInput) // revisited
		
		duplicateSpacers(factory, workingInput) // refactored
		
		replaceNamedColorsWithHexColors(factory, workingInput) // revisited
		
		mergeNestedWorkflows(factory, workingInput)
		
		replaceCombinedActionWithCustomAction(factory, workingInput) // refactored
		
		createAutoGenerationAction(factory, workingInput, autoGenerators)  // refactored
		
		createViewElementsForAutoGeneratorAction(factory, workingInput, autoGenerators)
		
		cloneContainerElementReferencesIntoParentContainer(factory, workingInput, clonedElements, containerRefs)
		
		cloneViewElementReferencesIntoParentContainer(factory, workingInput, clonedElements, viewRefsDone)
		
		replaceStyleRefernces(factory, workingInput)
		
		simplifyReferencesToAbstractViewGUIElements(factory, workingInput, clonedElements)
		
		remapToClonedGUIElements(factory, workingInput, clonedElements, mappingTasks, autoMappingTasks, userMappingTasks)
		
		cleanUpUnnecessaryMappings(factory, workingInput, autoMappingTasks, userMappingTasks)
		
		createValidatorsForModelConstraints(factory, workingInput, autoMappingTasks, userMappingTasks, userValidatorBindingTasks)
		
		copyValidatorsToClonedGUIElements(factory, workingInput, clonedElements, userValidatorBindingTasks)
		
		createValidatorsForModelConstraints(factory, workingInput, autoMappingTasks, userMappingTasks, userValidatorBindingTasks)
		
		copyEventsToClonedGUIElements(factory, workingInput, clonedElements)
		
		copyAllCustomCodeFragmentsToClonedGUIElements(factory, workingInput, clonedElements)
		
		transformInputsWithLabelsAndTooltipsToLayouts(factory, workingInput) // new
		
		// Remove redundant elements
		val Collection<EObject> objectsToRemove = newHashSet()
		objectsToRemove.addAll(autoGenerators)
		objectsToRemove.addAll(containerRefs)
		objectsToRemove.addAll(viewRefsDone)
		for (objRemove : objectsToRemove) {
			switch (objRemove) {
				ViewGUIElement: objRemove.eContainer.remove
				ContainerElementRef: objRemove.remove
				ViewElementRef: objRemove.remove				
			}
		}
		
		// after clean-up calculate all grid and element sizes and fill empty cells with spacers,
		// so that calculations are avoided during the actual generation process
		transformFlowLayoutsToGridLayouts(factory, workingInput) // new
		
		calculateNumRowsAndNumColumnsParameters(factory, workingInput) // new
		
		fillUpGridLayoutsWithSpacers(factory, workingInput) // new
		
		calculateAllViewElementWidths(factory, workingInput) // new
		
		
		// Return new ResourceSet
		workingInput.resolveAll
		workingInput
	}
	
}
