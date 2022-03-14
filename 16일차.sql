/*
    신입생이 들어왔습니다.
    학생정보 입력 익명블록을 작성하시오.
    입력값 : 이름, 주소, 전공, 생년월일은
    학번은 생성( 학번의 앞 4자리는 년도로 올해 년도와 같다면 마지막 학번 + 1로 생성
                                     올해 년도와 같지 않다면 202200001 번으로 생성 )   
*/
DECLARE
 vn_year varchar2(4) := to_char(sysdate, 'YYYY');
 vn_newyear number;
 vn_lastyear number;
 -- 필요한 변수 생성
BEGIN
 -- 마지막 학번 조회
  select max(학번)
   into vn_lastyear
  from 학생;
      -- 앞 4자리 비교
      if vn_year = substr(to_char(vn_lastyear),1,4) then
        vn_newyear := vn_lastyear + 1;
      else
        vn_newyear := to_number(vn_year || '000001');
      end if;
 -- 학번 생성
 INSERT INTO 학생 (학번, 이름, 주소, 전공, 생년월일)
 VALUES (vn_newyear, :이름, :주소, :전공, TO_DATE(:생년월일)) ;
END;

select 이름
     , 학번
from 학생;

/*
    YYYYMMDD 형식의 문자타입 데이터를 입력받아
    오늘 날짜와 비교하여 지났다면 얼마나 지났는지
              지나지 않았다면 얼마나 남았는지 출력하시오 (네이버 dday 기준)
    2022.12.25      오늘부터 기준일까지는 292일 남았습니다.
    2022.01.01      기준일부터 67일 째 되는 날입니다.
    입력 : 문자열            오늘 날짜와 큰지, 같은지, 작은지 조건문
    리턴 : 문자열
*/

create or replace function fn_dday (num1 number)
return varchar2
is
a number := to_date(num1) - sysdate;
b number := abs(trunc(a));
c varchar2(1000);
begin
if b = 0 then
    c := '현재 날짜입니다.';
elsif b > 0 then
    c := '오늘부터 기준일까지는 ' || b || ' 일 남았습니다.';
else
    c := '오늘은 기준일부터 ' || b || ' 째 되는 날입니다.';
end if;
return c;
end;

CREATE OR REPLACE FUNCTION fn_dday(dday VARCHAR2)
 RETURN VARCHAR2
IS
 vs_x VARCHAR2(4000);
BEGIN
   vs_x := ABS(ROUND(SYSDATE - TO_DATE(dday)));
   DBMS_OUTPUT.PUT_LINE(vs_x);
  IF vs_x < 0 THEN
     vs_x := '오늘부터 기준일 까지는' || vs_x || '일 남았습니다.';
  ELSIF vs_x > 0 THEN
     vs_x := '오늘은 기준일 부터' || vs_x || '일 째 되는날 입니다.';
  ELSE
     vs_x := '오늘이 D-DAY 입니다.';
  END IF;
 RETURN vs_x;
END; 

select fn_dday('20220303')
from dual;



select trunc(sysdate - to_date('20221225'))
from dual;


select fn_dday('20220101')
from dual;

select to_number(to_date('20221225') - to_date('20220101'))
from dual;