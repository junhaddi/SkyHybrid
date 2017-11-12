RUN(() => {
	INIT_OBJECTS();
	
	Native.setRegisterPushKeyHandler((pushKey) => {
		alert('푸시 키 : ' + pushKey);
		
		POST({
			url : 'http://192.168.0.7:8112/save-android-push-key',
			params : {
				pushKey : pushKey
			}
		}, {
			error : () => {
				alert('푸시 키를 서버에 저장할 수 없습니다.');
			},
			success : (result) => {
				alert('푸시 키 서버 저장 완료: ' + result);
			}
		});
	});
	
	let buttonStyle = {
		display : 'block',
		backgroundColor : '#333',
		color : '#fff',
		padding : 20,
		borderRadius : 10,
		textAlign : 'center',
		fontSize : 20,
		marginBottom : 10
	};
	
	A({
		style : buttonStyle,
		c : '구매한 물품 가져오기',
		on : {
			tap : () => {
				
				Native.loadPurchased({
					error : () => {
						alert('구매한 물품을 가져올 수 없습니다. 인터넷 연결을 확인해 주시기 바랍니다.');
					},
					success : (dataSet) => {
						alert(JSON.stringify(dataSet));
					}
				});
			}
		}
	}).appendTo(BODY);
	
	A({
		style : buttonStyle,
		c : '결제 테스트 (iap_test_item)',
		on : {
			tap : () => {
				
				Native.purchase('iap_test_item', {
					error : () => {
						alert('결제할 수 없습니다. 인터넷 연결을 확인해 주시기 바랍니다.');
					},
					cancel : () => {
						alert('결제를 취소하였습니다.');
					},
					success : (dataSet) => {
						alert(JSON.stringify(dataSet));
					}
				});
			}
		}
	}).appendTo(BODY);
	
	A({
		style : buttonStyle,
		c : '푸시 키 재생성',
		on : {
			tap : () => {
				Native.removePushKey();
				Native.generateNewPushKey();
			}
		}
	}).appendTo(BODY);
	
	A({
		style : buttonStyle,
		c : '유니티 광고 보기',
		on : {
			tap : () => {
				
				RUN((retry) => {
					
					Native.showUnityAd({
						error : () => {
							alert('유니티 광고를 볼 수 없습니다. 인터넷 연결을 확인해 주시기 바랍니다.');
							
							retry();
						},
						success : () => {
							alert('유니티 광고 시청 완료');
						}
					});
				});
			}
		}
	}).appendTo(BODY);
	
	A({
		style : buttonStyle,
		c : '구글 게임 서비스 로그인',
		on : {
			tap : () => {
				
				Native.loginGameService({
					error : () => {
						alert('구글 게임 서비스 로그인에 실패하였습니다.');
					},
					success : () => {
						alert('로그인 성공!');
					}
				});
			}
		}
	}).appendTo(BODY);
	
	A({
		style : buttonStyle,
		c : '구글 게임 업적 보기',
		on : {
			tap : () => {
				
				Native.showAchievements();
			}
		}
	}).appendTo(BODY);
});