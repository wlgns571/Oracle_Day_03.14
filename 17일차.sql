/* DROP FUNCTION 함수이름 -- 함수 삭제
*/

DROP FUNCTION my_mod;

-- 국가번호 입력받아 국가 테이블에서 국가명을 반환하는 함수 작성
-- 국가 명이 없을 경우 '해당국가 없음'을 반환
DECLARE
 vs_con varchar2(100);
BEGIN
 select country_name
 into vs_con
 from countries
 where country_id = 1234;
 DBMS_OUTPUT.PUT_LINE(vs_con);
END;

select country_name
from countries
where country_id = 1234;

create or replace function fn_get_country_name(p_country_id number)
 return varchar2
is
 vn_cnt number;
 vs_country_name countries.country_name%type;
begin
 select count(*)
 into vn_cnt
 from countries
 where country_id = p_country_id;
  if vn_cnt = 0 then
   vs_country_name := '해당국가 없음';
  else
   select country_name
   into vs_country_name
   from countries
   where country_id = p_country_id;
  end if;
  
  return vs_country_name;
end;

select fn_get_country_name(52790)
     , fn_get_country_name(1234)
from dual;

/* PROCEDURE 프로시져
   함수와 가장 큰 차이점은 리턴 값을 0 ~ N 개로 설정 할 수 있다.
   DLM문에서 사용 불가 (select, insert, delete)
   프로시져는 DB SERVER에서 실행(호출), 함수는 CLIENT 클라이언트 쪽에서 실행
   
   IN ( 프로시져 내부에서만 사용 )
   OUT ( 리턴에 사용 ) -- out 함수 사용 할때는 리턴받아 올 수 있는 변수로 출력 해야한다.
   IN OUT ( 내부, 리턴 모두 사용 )
*/
CREATE OR REPLACE PROCEDURE my_test_proc(
    p_var1 varchar2 -- default in
  , p_var2 out varchar2
  , p_var3 in out varchar2  )
IS
BEGIN
 DBMS_OUTPUT.PUT_LINE('p_var1 : ' || p_var1);
 DBMS_OUTPUT.PUT_LINE('p_var2 : ' || p_var2);
 DBMS_OUTPUT.PUT_LINE('p_var3 : ' || p_var3);
 p_var2 := 'B2';
 p_var3 := 'C2';
END;

declare
 v_var1 varchar2(10) := 'A';
 v_var2 varchar2(10) := 'B';
 v_var3 varchar2(10) := 'C';
begin
 my_test_proc(v_var1, v_var2, v_var3);
 DBMS_OUTPUT.PUT_LINE('프로시져 실행 후');
 DBMS_OUTPUT.PUT_LINE('p_var2 : ' || v_var2);
 DBMS_OUTPUT.PUT_LINE('p_var3 : ' || v_var3);
end;

/* 시스템 예외 (오라클에서 정의한 오류)
*/
create or replace procedure no_exception_proc
is
 vi_num number := 0;
begin
 vi_num := 10 / 0;
 DBMS_OUTPUT.PUT_LINE('success!');
end;

-- 예외처리 한 프로시져
create or replace procedure exception_proc
is
 vi_num number := 0;
begin
 vi_num := 10 / 0;
 DBMS_OUTPUT.PUT_LINE('success!');
 exception when ZERO_DIVIDE then
           -- SQLCODE : 오류 코드리턴
           -- SQLERRM : 오류 메시지 리턴
           -- DBMS_UTILITY.FORMAT_ERROR_BACKTRACE <-- 오류 프로시져 및 오류라인 출력
           DBMS_OUTPUT.PUT_LINE(SQLCODE);
           DBMS_OUTPUT.PUT_LINE(SQLERRM);
           DBMS_OUTPUT.PUT_LINE(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
           DBMS_OUTPUT.PUT_LINE('0으로 나눌수 없는 오류');
           when others then
           DBMS_OUTPUT.PUT_LINE('오류남!');
end;

begin
 no_exception_proc; -- 오류나서 멈춤
 dbms_output.put_line('성공');
end;

begin
 exception_proc;  -- 오류가 났지만 예외처리 후 다음로직 수행
 dbms_output.put_line('성공');
end;

/* 구분, 부서아이디, 부서명 을 입력받아
   구분의 값에 따라 ( I or U or D )
   INSERT, UPDATE, DELETE 하는 프로시져를 작성하시오.
   ex) exec dep_proc('I', 300, '빅데이터팀'); 부서 테이블에 id:300, name:빅데이터팀 삽입
       exec dep_proc('U', 300, '인공지능팀'); 부서 테이블에 id:300의 값 수정
       exec dep_proc('D', 300); 부서 테이블에 id:300 삭제
   
*/
-- out 변수를 추가하고
-- 정상처리시 Y리턴
-- 오류시 N을 리턴하시오
create or replace procedure dep_proc(
    p_yn out varchar2 
  , p_flag varchar2
  , p_id   number
  , p_nm   varchar2 default null -- 해당자리에 매개변수 없을 때 default값으로 매핑
)
is
begin
 if 'I' = p_flag then
  DBMS_OUTPUT.PUT_LINE('INSERT!');
  p_yn := 'Y';
  insert into departments (department_id, department_name)
  values (p_id, p_nm);
 elsif 'U' = p_flag then
  DBMS_OUTPUT.PUT_LINE('UPDATE!');
  p_yn := 'Y';
  update departments 
  set department_name = p_nm
  where department_id = p_id;
 elsif 'D' = p_flag then
  DBMS_OUTPUT.PUT_LINE('DELETE!');
  p_yn := 'Y';
  delete departments
  where department_id = p_id;
 end if;
 commit; -- 정상적으로 완료 되었다면 commit 필수
 DBMS_OUTPUT.PUT_LINE('정상종료');
exception when others then
 DBMS_OUTPUT.PUT_LINE('데이터를 확인하시오.');
 p_yn := 'N';
end;

declare
 yn varchar2(2);
begin
 dep_proc(yn, 'I', 300, '빅데이터팀');
 DBMS_OUTPUT.PUT_LINE(yn);
end;

exec dep_proc('I', 300, '빅데이터팀');

declare
begin
 dep_proc('U', 300, '인공지능팀');
end;

exec dep_proc('U', 300, '인공지능팀');

declare
begin
 dep_proc('D', 300);
end;

exec dep_proc('D', 300);

select *
from departments;
