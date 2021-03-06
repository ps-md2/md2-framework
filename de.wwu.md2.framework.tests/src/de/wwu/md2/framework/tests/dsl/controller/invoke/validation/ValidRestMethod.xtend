package de.wwu.md2.framework.tests.dsl.controller.invoke.validation

import org.eclipse.xtext.junit4.InjectWith
import de.wwu.md2.framework.MD2InjectorProvider
import org.junit.runner.RunWith
import org.eclipse.xtext.junit4.XtextRunner
import javax.inject.Inject
import org.eclipse.xtext.junit4.util.ParseHelper
import de.wwu.md2.framework.mD2.MD2Model
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.junit.Before
import static extension de.wwu.md2.framework.tests.utils.ModelProvider.*

import org.junit.Test
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import de.wwu.md2.framework.validation.ControllerValidator
import de.wwu.md2.framework.mD2.MD2Package

@InjectWith(typeof(MD2InjectorProvider))
@RunWith(typeof(XtextRunner))
class ValidRestMethod {

    @Inject extension ParseHelper<MD2Model>
    @Inject extension ValidationTestHelper
    ResourceSet rs;

    @Before
    def void setUp() {
        rs = new ResourceSetImpl();
        BASIC_CONTROLLER_V.load.parse(rs);
        INVOKE_REQUIREDATTRIBUTE_M.load.parse(rs);
        INVOKE_W.load.parse(rs);
    }
    
    /**
     * REST Param is GET
     */
    @Test
    def testWrongRestParam(){
        var controllerModel = INVOKE_RESTPARAM_C.load.parse(rs);
        controllerModel.assertError(MD2Package::eINSTANCE.invokeDefinition, ControllerValidator::UNSUPPORTEDRESTMETHOD);        
    }
}
