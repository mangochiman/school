if(typeof(ONEGEEK)=="undefined"){
    ONEGEEK={};

}
if(typeof ONEGEEK.forms=="undefined"){
    ONEGEEK.forms={
        FIELD_STATUS_RESET:0,
        FIELD_STATUS_ERROR:1,
        FIELD_STATUS_OK:2,
        FIELD_STATUS_INFO:3,
        FIELD_STATUS_NONE:4,
        FIELD_STATUS_EMPTY:5
    };

}
ONEGEEK.forms.DOMUtilities=function(){
    this.findPos=function(obj){
        var curleft=0;
        var curtop=0;
        if(obj.offsetParent){
            do{
                curleft+=obj.offsetLeft;
                curtop+=obj.offsetTop;
            }while((obj=obj.offsetParent));
        }
        return[curleft,curtop];
    };

    this.togglePopup=function(source,target){
        var div=target;
        var coords=this.findPos(source);
        if(!_du.hasClass(div,"hidden")){
            this.addClass(div,"hidden");
        }else{
            div.style.position="absolute";
            div.style.left=coords[0]+10+"px";
            div.style.top=coords[1]-6+"px";
            this.removeClass(div,"hidden");
        }
    };

this.hasClass=function(element,className){
    var classes=element.className;
    var pattern=new RegExp(className,"g");
    if(pattern.test(classes)){
        return true;
    }
    return false;
};

this.removeClass=function(element,className){
    var classes=element.className;
    var regex="\b"+className+"\b";
    element.className=classes.replace(className,"");
};

this.addClass=function(element,className){
    var classes=element.className;
    if(!this.hasClass(element,className)){
        element.className+=" "+className;
    }
};

this.addEvent=function(element,event,handler){
    if(element.attachEvent){
        element.attachEvent("on"+event,handler);
    }else{
        if(element.addEventListener){
            element.addEventListener(event,handler,true);
        }else{
            if(!element.id){
                var date=new Date();
                element.id=date.getTime();
            }
            eval("document.getElementById("+element.id+").on"+event+"="+handler);
        }
    }
};

};

var _du=new ONEGEEK.forms.DOMUtilities();
function stopEvent(b){
    if(b){
        var a=typeof(b.stopPropagation);
        if(a=="function"){
            b.stopPropagation();
            b.preventDefault();
        }else{
            if(b.cancelBubble!==undefined){
                b.cancelBubble=true;
            }
        }
    }
return false;
}
Function.prototype.gbind=function(b,a){
    var c=this;
    return function(){
        return c.call(b,a);
    };

};

Function.prototype.gbindEvent=function(b,a){
    var c=this;
    return function(d){
        d=d||window.event;
        return c.call(b,d,a);
    };

};

Array.prototype.gcontains=function(b){
    for(var a in this){
        if(this[a]===b){
            return true;
        }
    }
    return false;
};

ONEGEEK.forms.AbstractFormField=function(b){
    this.field=b||null;
    this.successMsg="Completed";
    this.errorMsg="Please complete";
    this.contextMsg="Please complete";
    this.emptyMsg="%field% is required, please complete";
    this.msgSpan=null;
    this.isRequired=false;
    this.statusImg=null;
    this.statusLink=null;
    this.fieldStatus=null;
    this.modified=false;
    this.className=null;
    this.form=null;
    this.state=null;
    this.setOptions=function(c){
        for(var d in c){
            if(this[d]!=null){
                this["_"+d]=this[d];
            }
            this[d]=c[d];
        }
        };

this.setClassName=function(c){
    this.className=c;
};

this.setLang=function(f){
    f=f.toUpperCase();
    var c=null;
    try{
        this.setOptions(ONEGEEK.forms.GValidator.translation[f].defaults);
        this.setOptions(ONEGEEK.forms.GValidator.translation[f][this.className]);
    }catch(d){}
};

this.setup=function(){
    if(_du.hasClass(this.field,"required")){
        this.isRequired=true;
    }
    this.getMsgSpan();
    if(this.form.options.eMsgFormat=="compact"){
        this.createFieldStatusIcon();
    }
    this.createRequiredSpan();
    this.validate();
    _du.addEvent(this.field,"blur",this.applyFieldValidation(this));
    _du.addEvent(this.field,"click",this.applyContextInformation(this));
    _du.addEvent(this.field,"change",this.applyFieldModification(this));
    this.setLabel();
};

this.setLabel=function(){
    if(this.label){
        return true;
    }
    try{
        if(this.field.type!="checkbox"&&this.field.type!="radio"){
            var j=this.form.getForm().getElementsByTagName("label");
            for(var d=0;d<j.length;d++){
                if(j[d].getAttribute("for")==this.field.id){
                    this.label=j[d].innerHTML;
                    return true;
                }
            }
            }
        var g=this.field.parentNode;
var c="";
do{
    c=g.tagName.toLowerCase();
    if(c=="fieldset"){
        var f=g.getElementsByTagName("legend");
        if(f.length>0){
            this.label=f[0].innerHTML;
            return true;
        }
    }
    g=g.parentNode;
}while(g&&c!="form");
}catch(h){
    this.label="Field";
    return false;
}
this.label="Field";
return false;
};

this.setForm=function(c){
    this.form=c;
};

this.applyFieldModification=function(c){
    return function(){
        c.setModified(true);
    };

};

this.applyContextInformation=function(c){
    return function(){
        var d=c.getMsgSpan();
        if(d&&c.getModified()===false&&c.getDOMElement.value===""&&c.contextMsg){
            c.setState(ONEGEEK.forms.FIELD_STATUS_INFO);
        }
    };

};

this.applyFieldValidation=function(c){
    return function(){
        c.validate();
    };

};

this.setModified=function(c){
    this.modified=c;
};

this.getModified=function(){
    return this.modified;
};

this.reset=function(){
    this.setModified(false);
    this.setState(ONEGEEK.forms.FIELD_STATUS_RESET);
};

this.highlight=function(){
    if(!this.form.options.highlightFields){
        return;
    }
    _du.removeClass(this.field,this.form.options.highlightFields);
    switch(this.state){
        case ONEGEEK.forms.FIELD_STATUS_EMPTY:case ONEGEEK.forms.FIELD_STATUS_ERROR:
            _du.addClass(this.field,this.form.options.highlightFields.toString());
            break;
    }
};

this.setState=function(d){
    this.state=d;
    this.highlight();
    _du.removeClass(this.msgSpan,"error");
    _du.removeClass(this.msgSpan,"info");
    _du.removeClass(this.msgSpan,"ok");
    var g="";
    var f="";
    var e="";
    var c=null;
    switch(d){
        case ONEGEEK.forms.FIELD_STATUS_EMPTY:
            g=this.form.options.icons.error;
            e="There are errors with this field. Click for more info.";
            f="There are errors with this field. Click for more info.";
            this.emptyMsg=this.emptyMsg.replace("%field%","'"+this.label+"'");
            c=this.emptyMsg;
            _du.addClass(this.msgSpan,"error");
            break;
        case ONEGEEK.forms.FIELD_STATUS_ERROR:
            g=this.form.options.icons.error;
            e="There are errors with this field. Click for more info.";
            f="There are errors with this field. Click for more info.";
            c=this.errorMsg;
            _du.addClass(this.msgSpan,"error");
            break;
        case ONEGEEK.forms.FIELD_STATUS_OK:
            g=this.form.options.icons.ok;
            e="This field has been completed successfully.";
            f="This field has been completed successfully.";
            c=this.successMsg;
            _du.addClass(this.msgSpan,"ok");
            break;
        case ONEGEEK.forms.FIELD_STATUS_RESET:
            if(this.form.options.eMsgFormat=="compact"){
            _du.addClass(this.msgSpan,"hidden");
        }
        default:
            g=this.form.options.icons.info;
            e="Click for more information about this field.";
            f="Click for more information about this field.";
            c=this.contextMsg;
            _du.addClass(this.msgSpan,"info");
    }
    if(this.form.options.eMsgFormat=="compact"){
        this.statusImg.src=g;
        this.statusImg.alt=e;
        this.statusImg.title=f;
    }
    if(c!==null){
        this.msgSpan.innerHTML=c;
    }else{
        _du.addClass(this.msgSpan,"hidden");
    }
};

this.createRequiredSpan=function(){
    if(this.form.options.reqShow){
        var c=document.createElement("span");
        c.className="required";
        if(this.isRequired){
            c.innerHTML=this.form.options.reqChar;
        }else{
            c.innerHTML=" &nbsp;";
        }
        if(this.form.options.reqPlacement=="before"){
            this.field.parentNode.insertBefore(c,this.field.parentNode.firstChild);
        }else{
            this.field.parentNode.insertBefore(c,this.field);
        }
    }
};

this.createFieldStatusIcon=function(){
    if(this.fieldStatus===null){
        var e=this.field.parentNode.getElementsByTagName("span");
        for(var c=0;c<e.length;c++){
            if(_du.hasClass(e[c],"fieldstatus")){
                this.fieldStatus=e[c];
                return this.fieldStatus;
            }
        }
        var d=document.createElement("span");
    d.className="fieldstatus";
    this.statusImg=document.createElement("img");
    this.statusImg.src=this.form.options.icons.info;
    this.statusLink=document.createElement("a");
    _du.addEvent(this.statusLink,this.form.options.eMsgEventOn,a(this.statusLink,this.msgSpan));
    if(this.form.options.eMsgEventOff!==null){
        _du.addEvent(this.statusLink,this.form.options.eMsgEventOff,a(this.statusLink,this.msgSpan));
    }
    this.statusLink.appendChild(this.statusImg);
    d.appendChild(this.statusLink);
    this.fieldStatus=this.field.parentNode.insertBefore(d,this.getMsgSpan());
    return this.fieldStatus;
}else{
    return this.fieldStatus;
}
};

var a=function(d,c){
    return function(){
        _du.togglePopup(d,c);
    };

};

this.getMsgSpan=function(){
    if(this.msgSpan===null){
        var e=this.field.parentNode.getElementsByTagName("span");
        for(var c=0;c<e.length;c++){
            if(_du.hasClass(e[c],"msg")){
                this.msgSpan=e[c];
                return this.msgSpan;
            }
        }
        var d=document.createElement("span");
    if(this.form.options.eMsgFormat=="compact"){
        d.className="msg hidden info";
    }else{
        d.className="msg icon info";
    }
    d.innerHTML=this.contextMsg;
    this.msgSpan=this.field.parentNode.appendChild(d);
}
return this.msgSpan;
};

this.validate=function(){
    if(this.field.value){
        this.setState(ONEGEEK.forms.FIELD_STATUS_OK);
        return true;
    }
    if(this.modified===false){
        this.setState(ONEGEEK.forms.FIELD_STATUS_INFO);
    }else{
        this.setState(ONEGEEK.forms.FIELD_STATUS_EMPTY);
    }
    return false;
};

this.clean=function(){};

this.getDOMElement=function(){
    return this.field;
};

this.isRequiredField=function(){
    return this.isRequired;
};

};

ONEGEEK.forms.FormFieldFactory=function(){
    var a=new Array();
    this.lookupFormField=function(b,d){
        if(a[b]!=null){
            var c=new (window.ONEGEEK.forms[a[b]["class"]])(d);
            c.setOptions(a[b].options);
            return c;
        }
        return null;
    };

    this.registerFormField=function(d,c,b){
        if(a[d]!=null){
            alert("FormFieldFactory registerFormField(): Cannot register field ("+d+"), as this namespace is in use");
            return;
        }
        a[d]={
            "class":c,
            options:b
        };

};

};

var formFieldFactory=new ONEGEEK.forms.FormFieldFactory();
ONEGEEK.forms.ComboBox=function(a){
    this.field=a;
    this.validate=function(){
        if(this.field.value&&this.field.value!==""){
            this.setState(ONEGEEK.forms.FIELD_STATUS_OK);
            return true;
        }
        if(this.modified===false||!this.isRequired){
            this.setState(ONEGEEK.forms.FIELD_STATUS_INFO);
        }else{
            this.setState(ONEGEEK.forms.FIELD_STATUS_EMPTY);
        }
        return false;
    };

    this.setup=function(){
        if(_du.hasClass(this.field,"required")){
            this.isRequired=true;
        }
        this.getMsgSpan();
        if(this.form.options.eMsgFormat=="compact"){
            this.createFieldStatusIcon();
        }
        this.createRequiredSpan();
        this.validate();
        _du.addEvent(this.field,"click",this.applyFieldValidation(this));
        _du.addEvent(this.field,"blur",this.applyFieldValidation(this));
        _du.addEvent(this.field,"click",this.applyContextInformation(this));
        _du.addEvent(this.field,"change",this.applyFieldModification(this));
        this.setLabel();
    };

};

ONEGEEK.forms.ComboBox.prototype=new ONEGEEK.forms.AbstractFormField();
formFieldFactory.registerFormField("select","ComboBox");
formFieldFactory.registerFormField("combo","ComboBox");
ONEGEEK.forms.Checkbox=function(a){
    this.field=a;
    this.clean=function(){};

    this.validate=function(){
        var b=document.forms[0].elements[this.field.name];
        if(b.length===undefined){
            b=[b];
        }
        for(i=0;i<b.length;i++){
            if(b[i].checked){
                this.setState(ONEGEEK.forms.FIELD_STATUS_OK);
                return true;
            }else{
                if(this.modified!==true||!this.isRequired){
                    this.setState(ONEGEEK.forms.FIELD_STATUS_INFO);
                }else{
                    this.setState(ONEGEEK.forms.FIELD_STATUS_EMPTY);
                }
            }
        }
        return false;
};

this.setup=function(){
    if(_du.hasClass(this.field,"required")){
        this.isRequired=true;
    }
    this.getMsgSpan();
    if(this.form.options.eMsgFormat=="compact"){
        this.createFieldStatusIcon();
    }
    this.createRequiredSpan();
    this.validate();
    var b=document.forms[0].elements[this.field.name];
    if(b.length===undefined){
        b=[b];
    }
    for(i=0;i<b.length;i++){
        _du.addEvent(b[i],"click",this.applyFieldValidation(this));
        _du.addEvent(b[i],"click",this.applyContextInformation(this));
        _du.addEvent(b[i],"change",this.applyFieldModification(this));
    }
    this.setLabel();
};

};

ONEGEEK.forms.Checkbox.prototype=new ONEGEEK.forms.AbstractFormField();
formFieldFactory.registerFormField("checkbox","Checkbox");
ONEGEEK.forms.RadioButton=function(a){
    this.field=a;
    this.clean=function(){};

    this.setup=function(){
        if(_du.hasClass(this.field,"required")){
            this.isRequired=true;
        }
        this.getMsgSpan();
        if(this.form.options.eMsgFormat=="compact"){
            this.createFieldStatusIcon();
        }
        this.createRequiredSpan();
        this.validate();
        var b=document.forms[0].elements[this.field.name];
        for(i=0;i<b.length;i++){
            _du.addEvent(b[i],"click",this.applyFieldValidation(this));
            _du.addEvent(b[i],"click",this.applyContextInformation(this));
            _du.addEvent(b[i],"change",this.applyFieldModification(this));
        }
        this.setLabel();
    };

    this.validate=function(){
        var b=document.forms[0].elements[this.field.name];
        for(i=0;i<b.length;i++){
            if(b[i].checked){
                this.setState(ONEGEEK.forms.FIELD_STATUS_OK);
                return true;
            }else{
                if(this.modified!==true||!this.isRequired){
                    this.setState(ONEGEEK.forms.FIELD_STATUS_INFO);
                }else{
                    this.setState(ONEGEEK.forms.FIELD_STATUS_EMPTY);
                }
            }
        }
        return false;
};

};

ONEGEEK.forms.RadioButton.prototype=new ONEGEEK.forms.AbstractFormField();
formFieldFactory.registerFormField("radio","RadioButton");
ONEGEEK.forms.AbstractTextField=function(a){
    this.field=a;
    this.regex="";
    this.cleanRegex="";
    this.pattern=null;
    this.validate=function(){
        if(this.field.value){
            this.clean();
            this.pattern=new RegExp(this.regex);
            var b=this.pattern.test(this.field.value);
            this.pattern.lastIndex=0;
            if(b){
                this.setState(ONEGEEK.forms.FIELD_STATUS_OK);
            }else{
                this.setState(ONEGEEK.forms.FIELD_STATUS_ERROR);
            }
            return b;
        }
        if(this.modified===false||this.isRequired===false){
            this.setState(ONEGEEK.forms.FIELD_STATUS_INFO);
        }else{
            this.setState(ONEGEEK.forms.FIELD_STATUS_EMPTY);
        }
        return false;
    };

    this.clean=function(){
        this.field.value=this.field.value.replace(this.cleanRegex,"");
    };

};

ONEGEEK.forms.AbstractTextField.prototype=new ONEGEEK.forms.AbstractFormField();
ONEGEEK.forms.NameField=function(a){
    this.field=a;
    this.regex=/^([a-zA-Z\-\'\s]{2,30})$/g;
    this.cleanRegex=/[^a-zA-Z\-\'\s]/g;
    this.errorMsg="Your name must be between 2 and 30 characters";
    this.contextMsg="Please enter your name";
};

ONEGEEK.forms.NameField.prototype=new ONEGEEK.forms.AbstractTextField();
formFieldFactory.registerFormField("firstname","NameField");
formFieldFactory.registerFormField("lastname","NameField");
formFieldFactory.registerFormField("name","NameField");
ONEGEEK.forms.PhoneField=function(a){
    this.field=a;
    this.regex=/^([0-9]{8,10})$/g;
    this.cleanRegex=/[^0-9]/g;
    this.errorMsg="At least 8 digits long";
    this.contextMsg=this.errorMsg;
};

ONEGEEK.forms.PhoneField.prototype=new ONEGEEK.forms.AbstractTextField();
formFieldFactory.registerFormField("phone","PhoneField");
ONEGEEK.forms.PasswordField=function(a){
    this.field=a;
    this.regex=/^.*(?=.{8,})(?=.*[a-z])(?=.*[A-Z])(?=.*[\d\W]).*$/;
    this.cleanRegex="";
    this.errorMsg="Please enter a password at least 8 characters in length using digits, lower and uppercase letters";
    this.contextMsg=this.errorMsg;
};

ONEGEEK.forms.PasswordField.prototype=new ONEGEEK.forms.AbstractTextField();
formFieldFactory.registerFormField("password","PasswordField");
ONEGEEK.forms.ConfirmPasswordField=function(a){
    this.field=a;
    this.errorMsg="Please confirm your password";
    this.contextMsg=this.errorMsg;
    this.validate=function(){
        if(this.field.value){
            this.clean();
            this.pattern=new RegExp(this.regex);
            var c=this.pattern.test(this.field.value);
            this.pattern.lastIndex=0;
            if(c){
                var b=document.getElementById("password");
                if(this.field.value!=b.value){
                    c=false;
                }
            }
            if(c){
            this.setState(ONEGEEK.forms.FIELD_STATUS_OK);
        }else{
            this.setState(ONEGEEK.forms.FIELD_STATUS_ERROR);
        }
        return c;
    }
    if(this.modified===false||this.isRequired===false){
        this.setState(ONEGEEK.forms.FIELD_STATUS_INFO);
    }else{
        this.setState(ONEGEEK.forms.FIELD_STATUS_EMPTY);
    }
    return false;
};

};

ONEGEEK.forms.ConfirmPasswordField.prototype=new ONEGEEK.forms.PasswordField();
formFieldFactory.registerFormField("confirmpassword","ConfirmPasswordField");
ONEGEEK.forms.EmailField=function(a){
    this.field=a;
    this.regex=/^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,4}$/i;
    this.errorMsg="Please enter a valid email address i.e. user@domain.com";
    this.contextMsg="This will be kept confidential";
    this.clean=function(){};

};

ONEGEEK.forms.EmailField.prototype=new ONEGEEK.forms.AbstractTextField();
formFieldFactory.registerFormField("email","EmailField");
ONEGEEK.forms.GenericTextField=function(a){
    this.field=a;
    this.regex=/[.\s]*/m;
    this.cleanRegex=/[<>\/\\\(\);]/g;
};

ONEGEEK.forms.GenericTextField.prototype=new ONEGEEK.forms.AbstractTextField();
formFieldFactory.registerFormField("text","GenericTextField");
formFieldFactory.registerFormField("generictext","GenericTextField");
ONEGEEK.forms.CaptchaTextField=function(a){
    this.field=a;
    this.regex=/^([A-Za-z0-9\-_]+)$/g;
    this.cleanRegex=/[<>\/\\\(\);]/g;
    this.successMsg="Thankyou.";
    this.errorMsg="Please complete the security check";
    this.contextMsg="This prevents us from spam";
};

ONEGEEK.forms.CaptchaTextField.prototype=new ONEGEEK.forms.AbstractTextField();
formFieldFactory.registerFormField("captcha","CaptchaTextField");
ONEGEEK.forms.RecaptchaTextField=function(a){
    this.field=a;
    this.contextMsg="Need some <a href='javascript:Recaptcha.showhelp()'>help</a>? Get another <a href='javascript:Recaptcha.reload()'>CAPTCHA</a>";
    this.errorMsg="Please complete. [Get another <a href='javascript:Recaptcha.reload()'>CAPTCHA</a>]";
};

ONEGEEK.forms.RecaptchaTextField.prototype=new ONEGEEK.forms.CaptchaTextField();
formFieldFactory.registerFormField("recaptcha_response_field","RecaptchaTextField");
formFieldFactory.registerFormField("recaptcha","RecaptchaTextField");
ONEGEEK.forms.Form=function(d){
    var a=new Array();
    var b=d||document.getElementById(d)||null;
    this.lang=null;
    this.custom=false;
    var c=["autoFocus","eMsgEventOn","eMsgEventOff","eMsgFormat","icons","error","info","ok","eMsgFunction","fMsg","fMsgFormat","reqShow","reqChar","reqPlacement","supressAlert","highlightFields"];
    this.options={
        icons:{
            ok:"../images/icons/tick.png",
            info:"../images/icons/help.png",
            error:"../images/icons/icon_alert.gif"
        },
        reqShow:true,
        reqChar:"*",
        reqPlacement:"after",
        fMsgFormat:"alert",
        fMsg:"Please correct the highlighted errors.",
        eMsgFormat:"open",
        eMsgEventOn:"click",
        eMsgEventOff:null,
        autoFocus:true,
        highlightFields:"highlight"
    };

    this.readOptions=function(e){
        this.options=this._readOptionsRecursive(this.options,e);
    };

    this._readOptionsRecursive=function(g,f){
        for(var j in f){
            if(c.gcontains(j)){
                try{
                    if(typeof(f[j])=="object"){
                        g[j]=this._readOptionsRecursive(g[j],f[j]);
                    }else{
                        g[j]=f[j];
                    }
                }catch(h){
                g[j]=f[j];
            }
        }
        }
        return g;
};

this.setOptions=function(){
    try{
        this.readOptions(ONEGEEK.forms.GValidator.options);
        if(this.custom===true){
            this.readOptions(ONEGEEK.forms.GValidator.options[b.id]);
        }
    }catch(f){}
};

this.reset=function(){
    for(var e=0;e<a.length;e++){
        a[e].reset();
    }
    };

this.getForm=function(){
    return b;
};

this.handleErrors=function(f){
    if(this.options.supressAlert!==true){

        jQuery.confirm({
            title:'Errors in Form',
            text:'Unable to submit form. Please correct the highlighted errors first and retry.',
            confirm: function(button) {
            },
            cancel: function(button) {
            },
            confirmButton: 'Okay'
        });


    }
    switch(typeof(this.options.fMsgFormat)){
        case"string":
            var j=document.getElementById("gvErrorsList");
            var k=document.getElementById(this.options.fMsgFormat);
            if(!k){
            break;
        }
        var g=document.createElement("ul");
            g.id="gvErrorsList";
            for(var h=0;h<f.length;h++){
            var e=document.createElement("li");
            if(f[h].state===ONEGEEK.forms.FIELD_STATUS_ERROR){
                e.innerHTML=f[h].errorMsg;
            }else{
                e.innerHTML=f[h].emptyMsg;
            }
            g.appendChild(e);
        }
        if(j){
            k.replaceChild(g,j);
        }else{
            k.appendChild(g);
        }
        _du.removeClass(k,"hidden");
            window.location="#"+this.options.fMsgFormat;
            break;
        case"function":
            return this.options.fMsgFormat(f);
        default:
            break;
    }
    return false;
};

this.validate=function(k){
    var j=null;
    var m=[];
    var l=[];
    for(var f=0;f<a.length;f++){
        a[f].setModified(true);
        var h=a[f].validate();
        if(!h){
            if((!a[f].isRequiredField()&&a[f].value!=null)||a[f].isRequiredField()){
                m[m.length]=a[f];
                l[l.length]=a[f].getDOMElement();
            }
        }
    }
    if(m[0]){
    l[0].focus();
    this.handleErrors(m);
    return stopEvent(k);
}
var g=b.getElementsByTagName("input");
for(f=0;f<g.length;f++){
    if(g[f].type=="submit"){
        g[f].disabled=true;
        g[f].value="Please wait...";
    }
}
return true;
};

this.applyFocus=function(){
    if(this.options.autoFocus===true){
        var e=document.getElementsByTagName("input");
        for(var f in e){
            if(e[f].type!="hidden"){
                e[f].focus();
                return true;
            }
        }
        }
    };

this.getFieldByName=function(e){
    var g=null;
    for(var f=0;f<a.length;f++){
        if(a[f].getDOMElement().name==e){
            return a[f];
        }
    }
    return g;
};

this.doForm=function(){
    if(b){
        this.lang=(b.lang)?b.lang:null;
        if(_du.hasClass(b,"custom")){
            this.custom=true;
        }
        this.setOptions();
        var f=b.getElementsByTagName("input");
        for(var h=0;h<f.length;h++){
            this.doFormField(f[h]);
        }
        var e=b.getElementsByTagName("textarea");
        for(h=0;h<e.length;h++){
            this.doFormField(e[h]);
        }
        var g=b.getElementsByTagName("select");
        for(h=0;h<g.length;h++){
            this.doFormField(g[h]);
        }
        _du.addEvent(b,"submit",this.validate.gbindEvent(this,"arg 2"));
        _du.addEvent(b,"reset",this.reset.gbind(this));
    }
};

this.doFormField=function(l){
    if(l&&l.type=="text"||l.type=="password"||l.type=="textarea"||l.type=="select-one"||l.type=="select-multiple"||l.type=="checkbox"||l.type=="file"||l.type=="radio"){
        if(!this.getFieldByName(l.name)){
            var k=l.className;
            var g=null;
            var e=0;
            if(k.indexOf(" ")>-1){
                var h=k.split(" ");
                do{
                    k=h[e];
                    g=formFieldFactory.lookupFormField(k,l);
                    e++;
                }while(g===null&&e<h.length);
            }else{
                g=formFieldFactory.lookupFormField(k,l);
            }
            if(g){
                g.setClassName(k);
                if(this.lang!==null){
                    g.setLang(this.lang);
                }
                var f=g.getDOMElement();
                g.setForm(this);
                g.setup();
                a[a.length]=g;
            }
        }
    }
};

};

ONEGEEK.forms.GValidator=function(){
    var a=[];
    this.getGForms=function(){
        return a;
    };

    this.getGForm=function(d){
        for(var b=0;b<a.length;b++){
            var c=a[b].getForm();
            if(c&&c.id==d){
                return a[b];
            }
        }
        };

this.readPlugins=function(){
    for(var b in ONEGEEK.forms.GValidator.plugins){
        formFieldFactory.registerFormField(b,ONEGEEK.forms.GValidator.plugins[b]._extends,ONEGEEK.forms.GValidator.plugins[b]);
    }
    };

this.applyFocus=function(){
    if(a.length>0){
        a[0].applyFocus();
    }
};

this.autoApplyFormValidation=function(){
    var b=document.getElementsByTagName("form");
    for(var c=0;c<b.length;c++){
        if(_du.hasClass(b[c],"autoform")||_du.hasClass(b[c],"gform")){
            a[c]=new ONEGEEK.forms.Form(b[c]);
            a[c].doForm();
        }
    }
    setTimeout(function(){
    this.applyFocus();
}.gbind(this),500);
};

this.readPlugins();
};

if(typeof(ONEGEEK.forms.GValidator.translation)=="undefined"){
    ONEGEEK.forms.GValidator.translation={};

}
function addLoadEventGVal(a){
    var b=window.onload;
    if(typeof window.onload!="function"){
        window.onload=a;
    }else{
        window.onload=function(){
            if(b){
                b();
            }
            a();
        };

}
}
addLoadEventGVal(function(){
    gvalidator=new ONEGEEK.forms.GValidator();
    gvalidator.autoApplyFormValidation();
});