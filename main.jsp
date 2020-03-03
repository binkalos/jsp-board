<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<% request.setCharacterEncoding("UTF-8"); %>
<%@ include file="../jslib.jsp" %>
<%@ include file="../inc/funcEtc.jsp" %>
<%@ include file="../inc/islogin.jsp" %>
<%@ include file="../inc/dbconn.jsp" %>
<%@ page import="org.json.simple.JSONArray"%>
<%@ page import="org.json.simple.JSONObject" %>
<%@ page autoFlush="true" buffer="1094kb"%>

<%@ page import = "java.sql.*"%>

<html>
<head>
<%@ include file="../inc/header.jsp" %>
<link rel="stylesheet" style="text/css" href="./css/mainstyle.css">
</head>
<body>
<%
try{
	//건물구하는sql
	String sqlList = "select t1.seq, t1.zonenm, t2.seq, t2.zone2nm from tb_zone2 as t2 join tb_zone as t1 on t1.seq = t2.seq_zone WHERE t1.seq = ?";
	pstmt = dbconn.prepareStatement(sqlList);
	pstmt.setInt(1, seqZone);
	rs = pstmt.executeQuery();
%>
<%@ include file = "../left.jsp" %>
<%@ include file = "../header.jsp" %>
<div class="main-wrapper"><!-- 전체 공간 -->
	<div class="select-wrapper"><!-- 선택할 때 나오는 공간 -->
		<div class="text-wrapper">
			<br>
			시설선택    
		</div>
		<div class="selectbtn-wrapper">
			<input type="button" value = "선택하기 + " class="selectbtn" name="selectbtn" class="selectbtn">
			<ul class="zone2nm-ul">
			<% 	while(rs.next()){
						String building = rs.getString("t2.zone2nm");//건물
						int t2seq = rs.getInt("t2.seq");%>
						<!-- 건물 -->
				<li id="zone2nm-li" class="zone2nm-li" value=<%=t2seq %>> <%=building%>
					<a href="javascript:;" class="zone2nmA" id="zone2nmA" style="color:black;">
					<img class="rightimg2" src="img/rightimg.png"></a>
				</li>
				<% }%>
			</ul>
			<!-- 층 -->
			<ul class="floor-ul" name="floor-ul" id="floor-ul">
				
			</ul>
			<!-- 시설 -->
			<ul class="zone3nm-ul" name="zone3nm-ul" id="zone3nm-ul">
	
			</ul>
			
			<div class="result-wrapper">
				<!-- 클릭한 결과 나오도록 하기 -->
			</div>
			
		</div><!-- 선택하기 + 버튼 -->

	</div><!-- select-wrapper -->
	<!--  <hr class="hr1">-->
	<div class="btn-wrapper"><!-- 일정 확인 버튼 공간 -->
		<input type="button" value="  일정 확인  " class="checkedbtn" name="checkedbtn" id="checkedbtn" onclick="javascript:;">
	</div>
	<div class="show-wrapper"><!-- 일정확인 버튼 누르면 결과보여줄 공간 -->
		<table class="finalresult">
			  
			<!-- 일정확인 결과 -->
		</table>
	</div><!-- show-wrapper -->
</div>
<script>
//클릭시 드롭다운
//html dom 이 다 로딩된 후 실행된다.
$(document).ready(function(){
	// menu 클래스 바로 하위에 있는 a 태그를 클릭했을때
	$(".selectbtn").click(function(){
	   var submenu = $(this).next(".zone2nm-ul");
	   // submenu 가 화면상에 보일때는 위로 보드랍게 접고 아니면 아래로 보드랍게 펼치기
	   if( submenu.is(":visible") ){
	       submenu.slideUp();
	   }else{
	       submenu.slideDown();
	   }
	});
	 /*클릭된게 확인 되면 옆 ul보여주기*/
	 $(".zone2nm-li").click(function(){
	 	var submenu2 = $(this).parent(".zone2nm-ul"); //console.log(submenu2);
	 	var submenu3 = $(submenu2).next(".floor-ul");// console.log(submenu3);
	 	/*아이디로 가지고 오는 방법*/
// 	 	var $subMenu3Id = $("#floor-ul");
// 	 	console.log($subMenu3Id);
// 	 	$subMenu3Id.slideDown();
	 	  if( submenu3.is(":visible") ){
// 		      submenu3.slideUp();
// 		      submenu3.slideDown();
		   }else {
		       submenu3.slideDown();
		   }
	 });
	 
	 /*ul외에 다른 곳 클릭하면 전부 ul display:none
	 $('html').click(function(e) {
		if(!$(e.target).hasClass(".select-wrapper")) { 
			alert('영역 밖입니다.'); 
		} 
	});

	 */
});

//결과 값을 누적해줄 배열 선언
//이 배열에는 t3의 seq가 저장 
var arrayResult = [];

$(function(){
		var zone2nmA= "";
		$(".zone2nm-li").on("click",function(){
	 		var zone2nmA= $(this).attr('value');
		 	//alert('건물seq : '+zone2nmA);
			 
		 	$.ajax({
		        url: "./submain.jsp",
		        data: {zone2nmA :zone2nmA},
		        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
		        type: "POST",
		        dataType : "json" ,
		        success:function(msg){
			        var $selectid = $('.floor-ul');
			        $selectid.empty();
			        $selectid.append('<li id="all" name="all" class="all"><a href="javascript:;" class="allA" style="color:black;">전체</a></li>');
			        
			        /*00관 전체 클릭하면 체크 이미지 나오게*/
			        $('.all').click(function(){
			        	if($(this).hasClass('zone2Selected')){
			        		$(this).removeClass('zone2Selected');
			        		// 이미지 버튼 지우기 추가
			        		$('#allCheckImg').remove();
			        	} else {
			        		$(this).append('<img class="checkimg" src="img/checkimg.png" id="allCheckImg">');//클릭된 그놈
				        	$(this).addClass('zone2Selected');
			        	}
			        	
			        });
			        
					$('.all').click(function(){
						//oo관 전체
						$.ajax({
					        url: "./allfloor.jsp",
					        data: {zone2nmA: zone2nmA},
					        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
					        type: "POST",
					        dataType : "json" ,
					        success:function(msg){
					        	console.log(msg);
						        var $selectid = $('.result-wrapper');
						       
						        $.each(msg, function makeSelect(index, item){
						        	$selectid.empty();
						        	$selectid.append('<button class="t2Result">'+'<img class="closeimg" src="img/closeimg.png">'+item.t2zone2nm+" 전체  "+'</button>');	    
						        	//클릭했을때 요소 제거
						        	$('.closeimg').click(function() {
						        		$('.t2Result').remove();
						        		$('#allCheckImg').remove();
						        	});

						        });//each
								
						        //all눌렀을때 결과버튼 지우기
						        if($('.all').hasClass('removeResultAll')){
					        		$('.all').removeClass('removeResultAll');
					        		$('.t2Result').remove();
					        	}else{
					        		$('.all').addClass('removeResultAll');
					        	}
						      
						        
						        
						        /*00관 전체 일정확인 결과 보여주기*/
								$(".checkedbtn").on("click",function(){

									 	$.ajax({
									        url: "./allfloor.jsp",
									        data: {zone2nmA:zone2nmA},
									        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
									        type: "POST",
									        dataType : "json" ,
									        success:function(msg){
										        var $selectid = $('.finalresult');
										        $selectid.empty();
										    	$selectid.append('<tr>'+
									        						'<td> 건물명 </td>'+
									        						'<td> 층 </td>'+
									        						'<td> 호 </td>'+
									        						'<td> 시설명 </td>'+
									        					  '</tr>');	
										        $.each(msg, function makeSelect(index, item){
										        	//일정확인 한 값 나오게
										        	$selectid.append('<tr>'+
										        						'<td>'+item.t2zone2nm+'</td>'+
										        						'<td>'+item.t3floor+"층  "+'</td>'+
										        						'<td>'+item.t3id+"호  "+'</td>'+
										        						'<td>'+item.t3zone3nm+'</td>'+
										        					  '</tr>');	
										        });//each
										        
										      
							        },//success
							        error:function(jqXHR,textStatus,errorThrown) {
							          console.log(jqXHR.status+'\n'+jqXHR.statusText)
							        }//error
							      });//ajax
								});   
						        
	
						        
			      			  },//success
			      			  error:function(jqXHR,textStatus,errorThrown) {
			     			     console.log(jqXHR.status+'\n'+jqXHR.statusText)
			      			  }//error
			    		  });//ajax
					});//all
							
				
			        $.each(msg, function makeSelect(index, item){
			        	$selectid.append('<li class="floor-li" value="'+item.t3floor+'">'+item.t3floor+" 층"+
			        	'<a href="javascript:;" class="floorA" id="floorA" name="floorA" style="color:black;">'+
			        	'<img class="rightimg2" src="img/rightimg.png">'+'</a>'+'</li>');
			  		});
			       
			    	var zone3nmA= "";
					$(".floor-li").on("click",function(){
							//00관 전체가 눌렸을때는 alert띄우고
				        	//alert(allCheck)
				        	
							var zone3nmA= $(this).attr('value');
						 	$.ajax({
						        url: "./submain2.jsp",
						        data: {zone3nmA :zone3nmA, zone2nmA: zone2nmA},
						        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
						        type: "POST",
						        dataType : "json" ,
						        success:function(msg){
						        	//console.log(msg);
						        	if($('.all').hasClass('zone3Selected')){
						        		//$('.checkimg').remove();
						         		 $(this).removeClass('zone3Selected');
						        		 //체크 이미지 삭제
						        		
						        		 alert("해당 건물의 전체 시설이 선택되어있습니다.");
						        	} else{ 
								        var $selectid = $('.zone3nm-ul');
								        $selectid.empty(); 
								        $selectid.append('<li class="all2">'+ '<a href="javascript:;" class="allA2" style="color:black;" >' +
								        				  zone3nmA +' 층 전체'+'</a></li>');
								        $.each(msg, function makeSelect(index, item){
								        	$selectid.append('<li class="zone3nm-li" name="zone3nm-li" id="zone3nm-'+item.t3seq+'">'+
								        					 "("+item.t3id+") "+item.t3zone3nm+
								        	'<a href="javascript:;" class="zone3nmA" id="'+item.t3seq+'" name="zone3nmA" style="color:black;">'+'</a>'+'</li>');
								        	
								        	//결과 담는 배열에 item.t3.seq 요소 있는지 확인 후 체크 이미지와 클래스 추가
								        	if(arrayResult.includes(item.t3seq)) {
								        	   $('#zone3nm-'+item.t3seq).append('<img class="checkimg" src="img/checkimg.png" id="img-'+item.t3seq+'">');//클릭된 그놈
											   $('#zone3nm-'+item.t3seq).addClass('zone3Selected');
								        	}
							   			  });//each
						  		   }//else
						  	     
							        /*시설 클릭되면 이미지추가 */
							        $('.zone3nm-li').click(function(){ 
							        	//alert("체크 이미지 지우는 함수에 입장! ");
							        	var result = $(this).attr('id');
							        	var zone3nmId = result.split('-')[1];//순수한 zone3nm-li의 t3seq값
							        	if($(this).hasClass('zone3Selected')){
									        $(this).removeClass('zone3Selected');
									        // 이미지 버튼 지우기 추가
									        $('#img-'+zone3nmId).remove();
									        //버튼결과 지우기 추가 
									    	$('#selected-'+zone3nmId).remove();
									        //배열에서 지우기
									    	for(var i = 0; i<arrayResult.length;i++){
				    		        			if(arrayResult[i]==zone3nmId){
				    			      				arrayResult.splice(i,1);
				    			      			}//if
				    		        		}
									     }else {
									        $(this).append('<img class="checkimg" src="img/checkimg.png" id="img-'+zone3nmId+'">');//클릭된 그놈
										    $(this).addClass('zone3Selected');
									        arrayResult.push(zone3nmId);
									    	var seqt3 = result.split('-')[1];//순수한 zone3nm-li의 t3seq값 
									    		//alert('건물:'+zone2nmA+' 층:'+zone3nmA+' 시설 :'+ result);
									        
									     	$.ajax({
									            url: "./submain3.jsp",
									            data: {result :seqt3, zone2nmA: zone2nmA, zone3nmA : zone3nmA},
									            contentType: "application/x-www-form-urlencoded; charset=UTF-8",
									            type: "POST",
									            dataType : "json" ,
									            success:function(msg){
									    	        var $selectid = $('.result-wrapper');
									            	//zone3nmli 에 class floorSelected가 있으면 다른 li클릭했을때 결과버튼 삭제
									    			if($('.all2').hasClass('floorSelected')){

									    				alert("해당 건물의 전체 시설이 선택되어있습니다.");
									    			} else {
									    	      	  $.each(msg, function makeSelect(index, item){
									    		        	//클릭한 값 나오게 띄워주기
									    		        	//console.log(msg);
									    		        	$selectid.append('<button class="result" id="selected-'+seqt3+'">'+
									    		        					 '<img class="closeimg" src="img/closeimg.png" id="img-'+seqt3+'">'+
									    		        					  item.t2zone2nm+" "+item.t3floor+"층  "+item.t3zone3nm+'</button>');	
									    		        	
									    	        	//클릭했을때 요소 제거
									    		        	$('.closeimg').click(function() {
									    		        		//1.버튼클릭시 아래 버튼 결과 삭제
									    		        		var result2 = $(this).attr('id');
									    		        		var result3 = result2.split('-')[1];//seqt3
									    		        		$('#selected-'+result3).remove();
									    		        		//2.체크이미지 삭제
									    		        		$('#img-'+result3+'.checkimg').remove();
									    		        		//3.배열에 들어간 값이 지우기버튼과 동일 한 값 클릭시 삭제
									    		        		//지우기 이미지 누른 값 배열에서 지워주기 이미지 id(result2)와 zone3nm-li의 li값이 같은 것
									    		        		for(var i = 0; i<arrayResult.length;i++){
									    		        			if(arrayResult[i]==result3){
									    			      				arrayResult.splice(i,1);
									    			      			}//if
									    		        		}//for
									    		        	});
									    		        });//each

									    		}//else

									    		},//success
									    		error:function(jqXHR,textStatus,errorThrown) {
									    		  console.log(jqXHR.status+'\n'+jqXHR.statusText)
									    		}//error
									    	});//ajax
									     }

							        	
							        });
							        
							        
							    	
							        /*시설 맨 위 전체(몇층 전체) 클릭하면 체크 이미지 나오게*/
							        $('.all2').click(function(){
							        	
							        	 if($(this).hasClass('floorSelected')){
									        	$(this).removeClass('floorSelected');
									        	// 이미지 버튼 지우기 추가
									        	$('#checkimg-all2').remove();
									        } else {
									        	$(this).append('<img id="checkimg-all2" class="checkimg" src="img/checkimg.png">');//클릭된 그놈
										        $(this).addClass('floorSelected');
									        }
							        });
							        
				
							        
									$('.all2').click(function(){
										//선택한 건물의 층의 전체
										$.ajax({
									        url: "./allzone3nm.jsp",
									        data: {zone2nmA: zone2nmA,zone3nmA:zone3nmA},
									        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
									        type: "POST",
									        dataType : "json" ,
									        success:function(msg){
										        var $selectid = $('.result-wrapper');
										        $.each(msg, function makeSelect(index, item){
										        	
										        	$selectid.append('<button class="t3Result" id="all2Id-'+item.t2seq+'_'+item.t3floor+'">'+
										        					 '<img class="closeimg" src="img/closeimg.png">'+
										        						item.t2zone2nm+" "+item.t3floor+"층  전체  "+
										        					 '</button>');	
										        	//alert('t2.seq'+item.t2seq);
										        	//클릭했을때 요소 제거                                                                                                                                                                                                                                                                                                                  
										        	$('.closeimg').click(function() {
										        		$('.t3Result').remove();
										        		$('.checkimg').remove();
										        	});
										        	//결과버튼 한번만 생기도록하기
													if($('.all2').hasClass('floorSelected_button')){
												        $('.all2').removeClass('floorSelected_button');
												        // 결과 버튼 지우기
												        $('#all2Id-'+item.t2seq+'_'+item.t3floor).remove();
												     } else {   
													    $('.all2').addClass('floorSelected_button');
							            			 }
											       
										        	
										        });//each
									       
										        //all2눌렀을때 결과버튼 지우기
										        if($('.all2').hasClass('removeResultAll2')){
									        		$('.all2').removeClass('removeResultAll2');
									        		$('.t3Result').remove();
									        	}else{
									        		$('.all2').addClass('removeResultAll2');
									        	}
										        
										        
										        
										        
												/*일정확인 누르면 table로 전체 누른 공간 보여주기*/
												$(".checkedbtn").on("click",function(){

													 	$.ajax({
													        url: "./allzone3nm.jsp",
													        traditional : true,//배열 보내주려고 사용
													        data: {zone2nmA: zone2nmA, zone3nmA: zone3nmA},
													        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
													        type: "POST",
													        dataType : "json" ,
													        success:function(msg){
														        var $selectid = $('.finalresult');
														        $selectid.empty();
														    	$selectid.append('<tr>'+
													        						'<td> 건물명 </td>'+
													        						'<td> 층 </td>'+
													        						'<td> 호 </td>'+
													        						'<td> 시설명 </td>'+
													        					  '</tr>');	
														        $.each(msg, function makeSelect(index, item){
														        	//일정확인 한 값 나오게
														        	$selectid.append('<tr>'+
														        						'<td>'+item.t2zone2nm+'</td>'+
														        						'<td>'+item.t3floor+"층  "+'</td>'+
														        						'<td>'+item.t3id+"호  "+'</td>'+
														        						'<td>'+item.t3zone3nm+'</td>'+
														        					  '</tr>');	
														        });//each
														        },//success
														        error:function(jqXHR,textStatus,errorThrown) {
														          console.log(jqXHR.status+'\n'+jqXHR.statusText)
														        }//error
												      });//ajax
													});   
							
												        
									        },//success
						      			  error:function(jqXHR,textStatus,errorThrown) {
						     			     console.log(jqXHR.status+'\n'+jqXHR.statusText)
						      			  }//error
								      });//ajax
									});//all2
							        						        
							        	
							        	
							    /*여기서부터 zone3nm까지 누르면 전체 값 보여주는 공간*/

										
										/*일정확인 누르면 table로 일정 보여주기*/
										$(".checkedbtn").on("click",function(){

											 	$.ajax({
											        url: "./callResult.jsp",
											        traditional : true,//배열 보내주려고 사용
											        data: {arrayResult:arrayResult},
											        contentType: "application/x-www-form-urlencoded; charset=UTF-8",
											        type: "POST",
											        dataType : "json" ,
											        success:function(msg){
												        var $selectid = $('.finalresult');
												        $selectid.empty();
												    	$selectid.append('<tr>'+
											        						'<td> 건물명 </td>'+
											        						'<td> 층 </td>'+
											        						'<td> 호 </td>'+
											        						'<td> 시설명 </td>'+
											        					  '</tr>');	
												        $.each(msg, function makeSelect(index, item){
												        	//일정확인 한 값 나오게
												        	$selectid.append('<tr>'+
												        						'<td>'+item.t2zone2nm+'</td>'+
												        						'<td>'+item.t3floor+"층  "+'</td>'+
												        						'<td>'+item.t3id+"호  "+'</td>'+
												        						'<td>'+item.t3zone3nm+'</td>'+
												        					  '</tr>');	
												        });//each
									        },//success
									        error:function(jqXHR,textStatus,errorThrown) {
									          console.log(jqXHR.status+'\n'+jqXHR.statusText)
									        }//error
									      });//ajax
										});   
							        
						        },//success
						        error:function(jqXHR,textStatus,errorThrown) {
						          console.log(jqXHR.status+'\n'+jqXHR.statusText)
						        }//error
						     });//ajax
					});
					
								
			        /*클릭된게 확인 되면 마지막 ul보여주기*/
			   	 $(".floor-li").click(function(){
			   	 	var submenu4 = $(this).parent(".floor-ul"); //console.log(submenu4);
			   	 	var submenu5 = $(submenu4).next(".zone3nm-ul"); //console.log(submenu5);
			    	  	if(submenu5.is(":visible") ){}
			    	  	else {submenu5.slideDown();}
			   	 });//click
			   	 
			   	 /*zone3nm-li클릭하면 체크 이미지나오게
		         $(".zone3nm-li").click(function(){
		        	 $('.checkimg').css("display","");
		         }); */
			   	 
		        },//success
		        error:function(jqXHR,textStatus,errorThrown) {
		          console.log(jqXHR.status+'\n'+jqXHR.statusText)
		        }
		     });//ajax
		});
});	//function

function callFunction(){

};

</script>
</body>
</html>
<%}
catch (Exception e) {
	e.printStackTrace();
}%>									
<%@ include file="../inc/dbclose.jsp"%>